# frozen_string_literal: true

require_relative "../../lib/decoding/decoders"

module Decoding
  RSpec.describe Decoders do
    include Decoders

    it "uses the decode function to decode a value using the given decoder" do
      expect(decode(string, "foo")).to eql(Result.ok("foo"))
    end

    it "matches string" do
      expect(decode(string, "foo")).to eql(Result.ok("foo"))
      expect(decode(string, 123)).to eql(Result.err("expected String, got Integer"))
    end

    it "matches integer" do
      expect(decode(integer, 123)).to eql(Result.ok(123))
      expect(decode(integer, 0.5)).to eql(Result.err("expected Integer, got Float"))
      expect(decode(integer, nil)).to eql(Result.err("expected Integer, got NilClass"))
    end

    it "matches float" do
      expect(decode(float, 123.0)).to eql(Result.ok(123.0))
      expect(decode(float, 123)).to eql(Result.err("expected Float, got Integer"))
    end

    it "matches numeric" do
      expect(decode(numeric, 123.0)).to eql(Result.ok(123.0))
      expect(decode(numeric, 123)).to eql(Result.ok(123))
      expect(decode(numeric, nil)).to eql(Result.err("expected Numeric, got NilClass"))
    end

    it "matches nil" do
      expect(decode(self.nil, nil)).to eql(Result.ok(nil))
      expect(decode(self.nil, 123)).to eql(Result.err("expected NilClass, got Integer"))
    end

    it "matches true" do
      expect(decode(self.true, true)).to eql(Result.ok(true))
      expect(decode(self.true, false)).to eql(Result.err("expected TrueClass, got FalseClass"))
    end

    it "matches false" do
      expect(decode(self.false, false)).to eql(Result.ok(false))
      expect(decode(self.false, true)).to eql(Result.err("expected FalseClass, got TrueClass"))
    end

    it "succeeds with a static value" do
      expect(decode(succeed(456), 123)).to eql(Result.ok(456))
    end

    it "fails with a static value" do
      expect(decode(fail(456), 123)).to eql(Result.err(456))
    end

    it "transforms a successfully decoded value with a block" do
      expect(decode(map(string, &:upcase), "foo")).to eql(Result.ok("FOO"))
      expect(decode(map(string, &:upcase), 123)).to be_err
    end

    it "decoders a value using the first matching of many decoders" do
      expect(decode(any(string, integer), 123)).to eql(Result.ok(123))
    end

    it "decodes any boolean value" do
      expect(decode(boolean, true)).to eql(Result.ok(true))
      expect(decode(boolean, false)).to eql(Result.ok(false))
    end

    it "decodes a value that may or may not be nil" do
      expect(decode(optional(string), "foo")).to eql(Result.ok("foo"))
      expect(decode(optional(string), nil)).to eql(Result.ok(nil))
    end

    it "decodes a field from a hash" do
      expect(decode(field("id", integer), "id" => 123)).to eql(Result.ok(123))
    end

    it "decodes an array of values using a decoder" do
      expect(decode(array(integer), [1, 2, 3])).to eql(Result.ok([1, 2, 3]))
    end

    it "decodes an array element by index using a decoder" do
      expect(decode(index(0, integer), [1, 2, 3])).to eql(Result.ok(1))
    end

    it "decodes a hash using two decoders" do
      expect(decode(hash(string, integer), { "john" => 1 })).to eql(Result.ok("john" => 1))
    end

    it "decodes a string to a symbol" do
      expect(decode(symbol, "foo")).to eql(Result.ok(:foo))
    end
  end
end
