# frozen_string_literal: true

require_relative "../../../lib/decoding/decoders"
require_relative "../../../lib/decoding/decoders/big_decimal"
require_relative "../../../lib/decoding/result"

module Decoding
  RSpec.describe Decoders do
    subject(:decoder) { Decoders.big_decimal }

    it "decodes a string describing a decimal number" do
      expect(decoder).to decode_value("1.23").to(BigDecimal("1.23"))
    end

    it "decodes an integer" do
      expect(decoder).to decode_value(42).to(BigDecimal("42"))
    end

    it "decodes a float" do
      expect(decoder).to decode_value(1.5).to(BigDecimal("1.5"))
    end

    it "passes through BigDecimal objects" do
      number = BigDecimal("1.23")
      expect(decoder).to decode_value(number).to(number)
    end

    it "fails given a string that does not describe a number" do
      expect(decoder).to decode_value("abc").failing_with('expected a decimal number, got "abc"')
    end

    it "fails given a value that is not a number or a string" do
      expect(decoder).to decode_value(nil).failing_with("expected a decimal number, got nil")
    end

    it "refuses a value that is not finite" do
      expect(decoder).to decode_value(Float::NAN).failing_with("expected a decimal number, got NaN")
      expect(decoder).to decode_value(Float::INFINITY).failing_with("expected a decimal number, got Infinity")
    end

    it "refuses a BigDecimal that is not finite" do
      expect(decoder).to decode_value(BigDecimal("NaN")).failing_with("expected a decimal number, got NaN")
    end

    it "reports where in a nested structure the error occurred" do
      expect(Decoders.field("amount", decoder))
        .to decode_value({ "amount" => "abc" }).failing_with('expected a decimal number, got "abc"').at("amount")
    end
  end
end
