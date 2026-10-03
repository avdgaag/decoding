# frozen_string_literal: true

require_relative "../../../lib/decoding/decoders"
require_relative "../../../lib/decoding/decoders/array"
require_relative "../../../lib/decoding/result"

module Decoding
  module Decoders
    RSpec.describe Array do
      it "succeeds using the given decoder" do
        expect(Array.new(Decoders.string)).to decode_value(["foo"]).to(["foo"])
      end

      it "fails when some items can not be decoded with the decoder" do
        expect(Array.new(Decoders.integer)).to decode_value(["foo"]).failing_with("expected Integer, got String").at(0)
      end

      it "stops decoding items at the first one that fails" do
        seen = []
        decoder = Array.new(
          Decoders.map(Decoders.original) do |item|
            seen << item
            Integer(item)
          end
        )
        expect(decoder).to decode_value([1, "x", 3, "y"]).failing_with(start_with("error in map block")).at(1)
        expect(seen).to eql([1, "x"])
      end

      it "fails when given something other than an array" do
        expect(Array.new(Decoders.integer)).to decode_value(true).failing_with("expected Array, got TrueClass")
      end
    end
  end
end
