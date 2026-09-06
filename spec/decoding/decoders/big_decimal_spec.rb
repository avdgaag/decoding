# frozen_string_literal: true

require_relative "../../../lib/decoding/decoders"
require_relative "../../../lib/decoding/decoders/big_decimal"
require_relative "../../../lib/decoding/result"

module Decoding
  RSpec.describe Decoders do
    it "decodes a string describing a decimal number" do
      Decoding.decode(Decoders.big_decimal, "1.23") => Decoding::Ok(number)
      expect(number).to eql(BigDecimal("1.23"))
    end

    it "decodes an integer" do
      Decoding.decode(Decoders.big_decimal, 42) => Decoding::Ok(number)
      expect(number).to eql(BigDecimal("42"))
    end

    it "decodes a float" do
      Decoding.decode(Decoders.big_decimal, 1.5) => Decoding::Ok(number)
      expect(number).to eql(BigDecimal("1.5"))
    end

    it "passes through BigDecimal objects" do
      number = BigDecimal("1.23")
      Decoding.decode(Decoders.big_decimal, number) => Decoding::Ok(result)
      expect(result).to eql(number)
    end

    it "fails given a string that does not describe a number" do
      Decoding.decode(Decoders.big_decimal, "abc") => Decoding::Err(msg)
      expect(msg).to eql('expected a decimal number, got "abc"')
    end

    it "fails given a value that is not a number or a string" do
      Decoding.decode(Decoders.big_decimal, nil) => Decoding::Err(msg)
      expect(msg).to eql("expected a decimal number, got nil")
    end

    it "refuses a value that is not finite" do
      Decoding.decode(Decoders.big_decimal, Float::NAN) => Decoding::Err(msg)
      expect(msg).to eql("expected a decimal number, got NaN")
      Decoding.decode(Decoders.big_decimal, Float::INFINITY) => Decoding::Err(other)
      expect(other).to eql("expected a decimal number, got Infinity")
    end

    it "refuses a BigDecimal that is not finite" do
      Decoding.decode(Decoders.big_decimal, BigDecimal("NaN")) => Decoding::Err(msg)
      expect(msg).to eql("expected a decimal number, got NaN")
    end

    it "reports where in a nested structure the error occurred" do
      decoder = Decoders.field("amount", Decoders.big_decimal)
      Decoding.decode(decoder, { "amount" => "abc" }) => Decoding::Err(msg)
      expect(msg).to eql('Error at .amount: expected a decimal number, got "abc"')
    end
  end
end
