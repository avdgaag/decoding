# frozen_string_literal: true

require_relative "../../../lib/decoding/decoders/match"

module Decoding
  module Decoders
    RSpec.describe Match do
      it "succeeds with values matching the given pattern" do
        expect(Match.new(/foo/)).to decode_value("foo bar").to("foo bar")
        expect(Match.new(String)).to decode_value("foo bar").to("foo bar")
      end

      it "errors with values not matching the given pattern" do
        expect(Match.new(/foo/)).to decode_value(123).failing_with("expected value matching /foo/, got 123")
        expect(Match.new(String)).to decode_value(nil).failing_with("expected String, got NilClass")
        expect(Match.new("other")).to decode_value(nil).failing_with(%(expected value matching "other", got nil))
      end
    end
  end
end
