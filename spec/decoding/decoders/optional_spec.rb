# frozen_string_literal: true

require_relative "../../../lib/decoding/decoders"
require_relative "../../../lib/decoding/decoders/optional"
require_relative "../../../lib/decoding/result"

module Decoding
  module Decoders
    RSpec.describe Optional do
      it "succeeds with the value decoded by the given decoder" do
        decoder = Optional.new(Decoders.string)
        expect(decoder.call("foo")).to eql(Result.ok("foo"))
      end

      it "succeeds with nil given a nil value" do
        decoder = Optional.new(Decoders.string)
        expect(decoder.call(nil)).to eql(Result.ok(nil))
      end

      it "lets the given decoder decode a nil value first" do
        decoder = Optional.new(Decoders.succeed(5))
        expect(decoder.call(nil)).to eql(Result.ok(5))
      end

      it "reports the failure of the given decoder" do
        decoder = Optional.new(Decoders.string)
        expect(Decoding.decode(decoder, 123)).to eql(Result.err("expected String, got Integer"))
      end

      it "retains the path of a nested failure" do
        decoder = Optional.new(Decoders.array(Decoders.integer))
        expect(Decoding.decode(decoder, [1, "x"])).to eql(Result.err("Error at .1: expected Integer, got String"))
      end
    end
  end
end
