# frozen_string_literal: true

require_relative "../../../lib/decoding/decoders"
require_relative "../../../lib/decoding/decoders/hash"
require_relative "../../../lib/decoding/result"

module Decoding
  module Decoders
    RSpec.describe Hash do
      it "succeeds using the given decoders" do
        hash = Hash.new(Decoders.string, Decoders.string)
        expect(hash.call({ "foo" => "bar" })).to eql(Result.ok({ "foo" => "bar" }))
      end

      it "fails when some items can not be decoded with the decoder" do
        hash = Hash.new(Decoders.string, Decoders.integer)
        expect(hash.call({ "foo" => "bar" }))
          .to eql(Result.err(Failure.new("expected Integer, got String").push("foo")))
      end

      it "combines its key with the path of a nested failure" do
        decoder = Decoders.field("data", Decoders.hash(Decoders.string, Decoders.array(Decoders.integer)))
        result = Decoding.decode(decoder, { "data" => { "scores" => [1, "x"] } })
        expect(result.unwrap_err(nil).to_s).to eql("Error at .data.scores.1: expected Integer, got String")
      end

      it "fails when given something other than an hash" do
        hash = Hash.new(Decoders.string, Decoders.integer)
        expect(hash.call(true)).to eql(Result.err(Failure.new("expected Hash, got TrueClass")))
      end

      it "fails when a key cannot be decoded" do
        hash = Hash.new(Decoders.integer, Decoders.string)
        expect(hash.call({ "foo" => "bar" }))
          .to eql(Result.err(Failure.new("invalid key: expected Integer, got String").push("foo")))
      end
    end
  end
end
