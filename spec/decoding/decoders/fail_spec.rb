# frozen_string_literal: true

require_relative "../../../lib/decoding/decoders/fail"

module Decoding
  module Decoders
    RSpec.describe Fail do
      it "always fails with the given message, ignoring input" do
        expect(Decoding.decode(Fail.new("oh no"), "anything")).to eql(Result.err("oh no"))
        expect(Decoding.decode(Fail.new("broken"), 42)).to eql(Result.err("broken"))
      end

      it "supports the decoder protocol" do
        expect(Fail.new("x")).to be_a(Decoding::Decoder)
        expect(Fail.new("x").to_decoder).to be_a(Decoding::Decoder)
      end

      it "composes with other decoders" do
        decoder = Decoding::Decoders::Any.new(Fail.new("nope"), Decoding::Decoders::Match.new(String))
        expect(Decoding.decode(decoder, "hello")).to eql(Result.ok("hello"))
      end
    end
  end
end
