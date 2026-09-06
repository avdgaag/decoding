# frozen_string_literal: true

require_relative "../../../lib/decoding/decoders"
require_relative "../../../lib/decoding/decoders/match"
require_relative "../../../lib/decoding/decoders/map"

module Decoding
  module Decoders
    RSpec.describe Map do
      let(:input) { { "id" => 1, "name" => "Ringo", "admin" => false } }

      it "transforms a successfully decoded value with a block" do
        expect(Map.new(Match.new(Integer)) { _1 * 2 }).to decode_value(4).to(8)
      end

      it "does not alter a failed decoding" do
        expect(Map.new(Match.new(Integer)) { _1 * 2 }).not_to decode_value("foo")
      end

      it "can decode using multiple decoders, yielding multiple values" do
        decoder = Map.new(
          Decoders.field("id", Decoders.integer),
          Decoders.field("name", Decoders.string),
          Decoders.field("admin", Decoders.boolean)
        ) { |id, name, admin| [id, name, admin] }
        expect(decoder).to decode_value(input).to([1, "Ringo", false])
      end

      it "fails if any of the multiple decoders fail" do
        decoder = Map.new(
          Decoders.field("id", Decoders.integer),
          Decoders.field("name", Decoders.integer),
          Decoders.field("admin", Decoders.boolean)
        ) { |id, name, admin| [id, name, admin] }
        expect(decoder).to decode_value(input).failing_with("expected Integer, got String").at("name")
      end

      it "handles errors in the map block" do
        failing_decoder = Map.new(Decoders.integer) do |_value|
          raise StandardError, "block error"
        end
        expect(failing_decoder).to decode_value(42).failing_with("error in map block: block error")
      end
    end
  end
end
