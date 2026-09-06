# frozen_string_literal: true

require_relative "../../../lib/decoding/decoders"
require_relative "../../../lib/decoding/decoders/index"
require_relative "../../../lib/decoding/result"

module Decoding
  module Decoders
    RSpec.describe Index do
      it "succeeds using the given decoder" do
        expect(Index.new(0, Decoders.string)).to decode_value(["foo"]).to("foo")
      end

      it "fails when some items can not be decoded with the decoder" do
        expect(Index.new(0, Decoders.integer)).to decode_value(["foo"]).failing_with("expected Integer, got String").at(0)
      end

      it "fails when the given index does not exist in the array" do
        expect(Index.new(1, Decoders.integer))
          .to decode_value([1]).failing_with("error decoding array: index 1 outside of array bounds: -1...1")
      end

      it "fails when given something other than an array" do
        expect(Index.new(0, Decoders.integer)).to decode_value(true).failing_with("expected Array, got TrueClass")
      end
    end
  end
end
