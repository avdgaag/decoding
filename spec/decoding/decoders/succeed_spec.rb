# frozen_string_literal: true

require_relative "../../../lib/decoding/decoders/succeed"

module Decoding
  module Decoders
    RSpec.describe Succeed do
      it "always succeeds with the given value, ignoring input" do
        expect(Succeed.new(42)).to decode_value("anything").to(42)
        expect(Succeed.new("hello")).to decode_value(nil).to("hello")
      end

      it "supports the decoder protocol" do
        expect(Succeed.new(1)).to be_a(Decoding::Decoder)
        expect(Succeed.new(1).to_decoder).to be_a(Decoding::Decoder)
      end

      it "composes with other decoders" do
        decoder = Decoding::Decoders::Field.new("x", Succeed.new(99))
        expect(decoder).to decode_value({ "x" => "ignored" }).to(99)
      end
    end
  end
end
