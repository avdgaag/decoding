# frozen_string_literal: true

require_relative "../../lib/decoding/decoders"

module Decoding
  RSpec.describe Decoders do
    it "uses the decode function to decode a value using the given decoder" do
      expect(Decoders.decode(Decoders.string, "foo")).to eql(Result.ok("foo"))
    end

    it "matches string" do
      expect(Decoders.string.call("foo")).to eql(Result.ok("foo"))
      expect(Decoders.string.call(123)).to eql(Result.err("expected value matching String, got: 123"))
    end

    it "matches integer" do
      expect(Decoders.integer.call(123)).to eql(Result.ok(123))
      expect(Decoders.integer.call(0.5)).to eql(Result.err("expected value matching Integer, got: 0.5"))
      expect(Decoders.integer.call(nil)).to eql(Result.err("expected value matching Integer, got: nil"))
    end

    it "matches float" do
      expect(Decoders.float.call(123.0)).to eql(Result.ok(123.0))
      expect(Decoders.float.call(123)).to eql(Result.err("expected value matching Float, got: 123"))
    end

    it "matches numeric" do
      expect(Decoders.numeric.call(123.0)).to eql(Result.ok(123.0))
      expect(Decoders.numeric.call(123)).to eql(Result.ok(123))
      expect(Decoders.numeric.call(nil)).to eql(Result.err("expected value matching Numeric, got: nil"))
    end

    it "matches nil" do
      expect(Decoders.nil.call(nil)).to eql(Result.ok(nil))
      expect(Decoders.nil.call(123)).to eql(Result.err("expected value matching NilClass, got: 123"))
    end

    it "matches true" do
      expect(Decoders.true.call(true)).to eql(Result.ok(true))
      expect(Decoders.true.call(false)).to eql(Result.err("expected value matching TrueClass, got: false"))
    end

    it "matches false" do
      expect(Decoders.false.call(false)).to eql(Result.ok(false))
      expect(Decoders.false.call(true)).to eql(Result.err("expected value matching FalseClass, got: true"))
    end

    it "succeeds with a static value" do
      expect(Decoders.succeed(456).call(123)).to eql(Result.ok(456))
    end

    it "fails with a static value" do
      expect(Decoders.fail(456).call(123)).to eql(Result.err(456))
    end

    it "transforms a successfully decoded value with a block" do
      expect(Decoders.map(Decoders.string, &:upcase).call("foo")).to eql(Result.ok("FOO"))
      expect(Decoders.map(Decoders.string, &:upcase).call(123)).to be_err
    end

    it "decoders a value using the first matching of many decoders" do
      expect(Decoders.any(Decoders.string, Decoders.integer).call(123)).to eql(Result.ok(123))
    end

    it "decodes any boolean value" do
      expect(Decoders.boolean.call(true)).to eql(Result.ok(true))
      expect(Decoders.boolean.call(false)).to eql(Result.ok(false))
    end

    it "decodes a value that may or may not be nil" do
      expect(Decoders.optional(Decoders.string).call("foo")).to eql(Result.ok("foo"))
      expect(Decoders.optional(Decoders.string).call(nil)).to eql(Result.ok(nil))
    end

    it "decodes a field from a hash" do
      expect(Decoders.field("id", Decoders.integer).call("id" => 123)).to eql(Result.ok(123))
    end

    it "decodes an array of values using a decoder" do
      expect(Decoders.array(Decoders.integer).call([1, 2, 3])).to eql(Result.ok([1, 2, 3]))
    end

    it "decodes an array element by index using a decoder" do
      expect(Decoders.index(0, Decoders.integer).call([1, 2, 3])).to eql(Result.ok(1))
    end
  end
end
