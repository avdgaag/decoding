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
      expect(Result.ok(123).unwrap(0)).to eql(123)
    end

    it "unwraps err values by returning the default value" do
      expect(Result.err(123).unwrap(0)).to eql(0)
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
  end
end
