# frozen_string_literal: true

require_relative "../../../lib/decoding/decoders/succeed"

module Decoding
  module Decoders
    RSpec.describe Succeed do
      it "always succeeds with the given value, ignoring input" do
        expect(Decoding.decode(Succeed.new(42), "anything")).to eql(Result.ok(42))
        expect(Decoding.decode(Succeed.new("hello"), nil)).to eql(Result.ok("hello"))
      end

      it "supports the decoder protocol" do
        expect(Succeed.new(1)).to be_a(Decoding::Decoder)
        expect(Succeed.new(1).to_decoder).to be_a(Decoding::Decoder)
      end

      it "composes with other decoders" do
        decoder = Decoding::Decoders::Field.new("x", Succeed.new(99))
        expect(Decoding.decode(decoder, { "x" => "ignored" })).to eql(Result.ok(99))
      end
    end
  end
end
