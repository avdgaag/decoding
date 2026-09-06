# frozen_string_literal: true

require_relative "../../../lib/decoding/decoders"
require_relative "../../../lib/decoding/decoders/lazy"
require_relative "../../../lib/decoding/result"

module Decoding
  module Decoders
    RSpec.describe Lazy do
      def tree_decoder
        Decoders.decode_hash(
          name: Decoders.field("name", Decoders.string),
          children: Decoders.field("children", Decoders.array(Decoders.lazy { tree_decoder }))
        )
      end

      it "decodes using the decoder returned by the block" do
        expect(Lazy.new { Decoders.string }).to decode_value("foo").to("foo")
      end

      it "does not build the decoder before decoding a value" do
        built = 0
        decoder = Lazy.new do
          built += 1
          Decoders.string
        end
        expect { decoder.call("foo") }.to change { built }.from(0).to(1)
      end

      it "builds the decoder only once" do
        built = 0
        decoder = Lazy.new do
          built += 1
          Decoders.string
        end
        2.times { decoder.call("foo") }
        expect(built).to be(1)
      end

      it "decodes a recursive structure" do
        input = { "name" => "a", "children" => [{ "name" => "b", "children" => [] }] }
        expect(tree_decoder).to decode_value(input).to({ name: "a", children: [{ name: "b", children: [] }] })
      end

      it "retains the path of a failure nested in a recursive structure" do
        input = { "name" => "a", "children" => [{ "name" => 1, "children" => [] }] }
        expect(tree_decoder).to decode_value(input).failing_with("expected String, got Integer").at("children", 0, "name")
      end
    end
  end
end
