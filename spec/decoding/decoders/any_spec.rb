# frozen_string_literal: true

require_relative "../../../lib/decoding/decoders"
require_relative "../../../lib/decoding/decoders/any"
require_relative "../../../lib/decoding/result"

module Decoding
  module Decoders
    RSpec.describe Any do
      it "succeeds using the given decoder" do
        any = Any.new(Decoders.string)
        expect(any.call("foo")).to eql(Result.ok("foo"))
      end

      it "succeeds using the first matching decoder if given multiple decoders" do
        any = Any.new(Decoders.integer, Decoders.float, Decoders.string)
        expect(any.call("foo")).to eql(Result.ok("foo"))
      end

      it "fails when none of the decoders match" do
        any = Any.new(Decoders.integer, Decoders.float, Decoders.string)
        expect(any.call(true)).to eql(Result.err("None of the decoders matched"))
      end
    end
  end
end
