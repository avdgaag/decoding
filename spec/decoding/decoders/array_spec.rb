# frozen_string_literal: true

require_relative "../../../lib/decoding/decoders"
require_relative "../../../lib/decoding/decoders/array"
require_relative "../../../lib/decoding/result"

module Decoding
  module Decoders
    RSpec.describe Array do
      it "succeeds using the given decoder" do
        decoder = Array.new(Decoders.string)
        expect(Decoding.decode(decoder, ["foo"])).to eql(Result.ok(["foo"]))
      end

      it "fails when some items can not be decoded with the decoder" do
        decoder = Array.new(Decoders.integer)
        expect(Decoding.decode(decoder, ["foo"])).to eql(Result.err("Error at .0: expected Integer, got String"))
      end

      it "fails when given something other than an array" do
        decoder = Array.new(Decoders.integer)
        expect(Decoding.decode(decoder, true)).to eql(Result.err("expected an Array, got: TrueClass"))
      end
    end
  end
end
