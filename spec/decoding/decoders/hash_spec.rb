# frozen_string_literal: true

require_relative "../../../lib/decoding/decoders"
require_relative "../../../lib/decoding/decoders/hash"
require_relative "../../../lib/decoding/result"

module Decoding
  module Decoders
    RSpec.describe Hash do
      it "succeeds using the given decoders" do
        expect(Hash.new(Decoders.string, Decoders.string)).to decode_value({ "foo" => "bar" }).to({ "foo" => "bar" })
      end

      it "fails when some items can not be decoded with the decoder" do
        expect(Hash.new(Decoders.string, Decoders.integer))
          .to decode_value({ "foo" => "bar" }).failing_with("expected Integer, got String").at("foo")
      end

      it "combines its key with the path of a nested failure" do
        decoder = Decoders.field("data", Decoders.hash(Decoders.string, Decoders.array(Decoders.integer)))
        expect(decoder)
          .to decode_value({ "data" => { "scores" => [1, "x"] } })
          .failing_with("expected Integer, got String").at("data", "scores", 1)
      end

      it "fails when given something other than an hash" do
        expect(Hash.new(Decoders.string, Decoders.integer)).to decode_value(true).failing_with("expected Hash, got TrueClass")
      end

      it "fails when a key cannot be decoded" do
        expect(Hash.new(Decoders.integer, Decoders.string))
          .to decode_value({ "foo" => "bar" }).failing_with("invalid key: expected Integer, got String").at("foo")
      end
    end
  end
end
