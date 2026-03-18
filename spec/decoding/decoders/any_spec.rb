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

      it "fails when none of the decoders match, collecting all failure reasons" do
        any = Any.new(Decoders.integer, Decoders.float, Decoders.string)
        result = any.call(true)
        result => Err[failure]
        expect(failure.to_s).to eql(
          "None of the decoders matched:\n  " \
          "- expected Integer, got TrueClass\n  " \
          "- expected Float, got TrueClass\n  " \
          "- expected String, got TrueClass"
        )
      end
    end
  end
end
