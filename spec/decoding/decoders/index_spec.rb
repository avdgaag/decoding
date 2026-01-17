# frozen_string_literal: true

require_relative "../../../lib/decoding/decoders"
require_relative "../../../lib/decoding/decoders/index"
require_relative "../../../lib/decoding/result"

module Decoding
  module Decoders
    RSpec.describe Index do
      it "succeeds using the given decoder" do
        index = Index.new(0, Decoders.string)
        expect(index.call(["foo"])).to eql(Result.ok("foo"))
      end

      it "fails when some items can not be decoded with the decoder" do
        index = Index.new(0, Decoders.integer)
        expect(index.call(["foo"])).to eql(Result.err(Failure.new("expected Integer, got String").push(0)))
      end

      it "fails when the given index does not exist in the array" do
        index = Index.new(1, Decoders.integer)
        expect(index.call([1])).to eql(Result.err(Failure.new("error decoding array: index 1 outside of array bounds: -1...1")))
      end

      it "fails when given something other than an array" do
        index = Index.new(0, Decoders.integer)
        expect(index.call(true)).to eql(Result.err(Failure.new("expected an Array, got: TrueClass")))
      end
    end
  end
end
