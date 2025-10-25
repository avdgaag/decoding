# frozen_string_literal: true

require_relative "../../lib/decoding/result"

module Decoding
  RSpec.describe Result do
    it "is frozen" do
      expect(Result.ok(123)).to be_frozen
      expect(Result.err(123)).to be_frozen
    end

    it "creates values that are equal by value" do
      expect(Result.ok(123)).to eql(Result.ok(123))
      expect(Result.err(123)).to eql(Result.err(123))
    end

    it "ok and err values are not equal" do
      expect(Result.ok(123)).not_to eql(Result.err(123))
    end

    it "has custom inspect output" do
      expect(Result.ok(123).inspect).to eql("#<Decoding::Ok 123>")
      expect(Result.err(123).inspect).to eql("#<Decoding::Err 123>")
    end

    it "only ok values are ok" do
      expect(Result.ok(123)).to be_ok
      expect(Result.err(123)).not_to be_ok
    end

    it "only err values are err" do
      expect(Result.ok(123)).not_to be_err
      expect(Result.err(123)).to be_err
    end

    it "unwraps ok values by returning the inner value" do
      expect(Result.ok(123).unwrap(0)).to be(123)
    end

    it "unwraps err values by returning the default value" do
      expect(Result.err(123).unwrap(0)).to be(0)
    end

    it "unwrap_err unwraps err values by returning the inner value" do
      expect(Result.err(123).unwrap_err(0)).to be(123)
    end

    it "unwrap_err unwraps ok values by returning the default value" do
      expect(Result.ok(123).unwrap_err(0)).to be(0)
    end

    it "creates new ok value by mapping with a block" do
      expect(Result.ok(123).map { _1 * 2 }).to eql(Result.ok(246))
    end

    it "returns the same value when mapping an err value" do
      expect(Result.err(123).map { _1 * 2 }).to eql(Result.err(123))
    end

    it "creates new err value by mapping err with a block" do
      expect(Result.err(123).map_err { _1 * 2 }).to eql(Result.err(246))
    end

    it "returns the same value when mapping err on an ok value" do
      expect(Result.ok(123).map_err { _1 * 2 }).to eql(Result.ok(123))
    end

    it "combines two ok values with a block or returns the first error" do
      expect(Result.ok(2).and(Result.ok(3)) { _1 + _2 }).to eql(Result.ok(5))
      expect(Result.ok(2).and(Result.err("error")) { _1 + _2 }).to eql(Result.err("error"))
      expect(Result.err("error").and(Result.ok(3)) { _1 + _2 }).to eql(Result.err("error"))
      expect(Result.err("error 1").and(Result.err("error 2")) { _1 + _2 }).to eql(Result.err("error 1"))
    end

    it "collapses an array of result values into a single result value if all are ok" do
      expect(Result.all([Result.ok(1), Result.ok(2)])).to eql(Result.ok([1, 2]))
      expect(Result.all([Result.ok(1), Result.err("error")])).to eql(Result.err("error"))
      expect(Result.all([])).to eql(Result.ok([]))
    end

    it "transforms a value using a block producing a result" do
      expect(Result.ok(5).and_then { Result.ok(_1 * 2) }).to eql(Result.ok(10))
      expect(Result.ok(5).and_then { Result.err("error") }).to eql(Result.err("error"))
      expect(Result.err("error").and_then { Result.ok(_1 * 2) }).to eql(Result.err("error"))
    end
  end
end
