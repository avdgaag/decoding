# frozen_string_literal: true

require_relative "../../../lib/decoding/decoders/fail"

module Decoding
  module Decoders
    RSpec.describe Fail do
      it "always fails with the given message, ignoring input" do
        expect(Fail.new("oh no")).to decode_value("anything").failing_with("oh no")
        expect(Fail.new("broken")).to decode_value(42).failing_with("broken")
      end

      it "supports the decoder protocol" do
        expect(Fail.new("x")).to be_a(Decoding::Decoder)
        expect(Fail.new("x").to_decoder).to be_a(Decoding::Decoder)
      end

      it "composes with other decoders" do
        decoder = Decoding::Decoders::Any.new(Fail.new("nope"), Decoding::Decoders::Match.new(String))
        expect(decoder).to decode_value("hello").to("hello")
      end
    end
  end
end
