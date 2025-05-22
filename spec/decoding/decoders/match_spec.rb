# frozen_string_literal: true

require_relative "../../../lib/decoding/decoders/match"

module Decoding
  module Decoders
    RSpec.describe Match do
      it "succeeds with values matching the given pattern" do
        expect(Decoding.decode(Match.new(/foo/), "foo bar")).to eql(Result.ok("foo bar"))
        expect(Decoding.decode(Match.new(String), "foo bar")).to eql(Result.ok("foo bar"))
      end

      it "errors with values not matching the given pattern" do
        expect(Decoding.decode(Match.new(/foo/), 123)).to eql(Result.err("expected value matching /foo/, got: 123"))
        expect(Decoding.decode(Match.new(String), nil)).to eql(Result.err("expected String, got NilClass"))
        expect(Decoding.decode(Match.new("other"), nil)).to eql(Result.err("expected value matching \"other\", got: nil"))
      end
    end
  end
end
