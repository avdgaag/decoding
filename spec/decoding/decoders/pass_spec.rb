# frozen_string_literal: true

require_relative "../../../lib/decoding/decoders/pass"

module Decoding
  module Decoders
    RSpec.describe Pass do
      it "always succeeds with its input value" do
        expect(Decoding.decode(Pass.new, "foo")).to eql(Result.ok("foo"))
      end
    end
  end
end
