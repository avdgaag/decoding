# frozen_string_literal: true

require_relative "../../../lib/decoding/decoders/match"

module Decoding
  module Decoders
    RSpec.describe Match do
      it "succeeds with values matching the given pattern" do
        expect(Match.new(/foo/).call("foo bar")).to eql(Result.ok("foo bar"))
        expect(Match.new(String).call("foo bar")).to eql(Result.ok("foo bar"))
      end

      it "errors with values not matching the given pattern" do
        expect(Match.new(/foo/).call(123)).to eql(Result.err("expected value matching /foo/, got: 123"))
        expect(Match.new(String).call(nil)).to eql(Result.err("expected value matching String, got: nil"))
      end
    end
  end
end
