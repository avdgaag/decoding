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
          .to eql(Result.err(Failure.new("error decoding value for key \"foo\": expected Integer, got String")))
      end

      it "fails when given something other than an hash" do
        hash = Hash.new(Decoders.string, Decoders.integer)
        expect(hash.call(true)).to eql(Result.err("expected Hash, got TrueClass"))
      end
    end
  end
end
