# frozen_string_literal: true

require_relative "../../../lib/decoding/decoders"
require_relative "../../../lib/decoding/decoders/array"
require_relative "../../../lib/decoding/result"

module Decoding
  module Decoders
    RSpec.describe Array do
      it "succeeds using the given decoder" do
        array = Array.new(Decoders.string)
        expect(array.call(["foo"])).to eql(Result.ok(["foo"]))
      end

      it "fails when some items can not be decoded with the decoder" do
        array = Array.new(Decoders.integer)
        expect(array.call(["foo"])).to eql(Result.err("error decoding array item 0: expected Integer, got String"))
      end

      it "fails when given something other than an array" do
        array = Array.new(Decoders.integer)
        expect(array.call(true)).to eql(Result.err("expected an Array, got: TrueClass"))
      end
    end
  end
end
