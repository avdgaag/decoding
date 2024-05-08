# frozen_string_literal: true

require_relative "../../lib/decoding/decoders"

module Decoding
  RSpec.describe Decoders do
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
  end
end
