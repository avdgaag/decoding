# frozen_string_literal: true

require_relative "../../lib/decoding/failure"

module Decoding
  RSpec.describe Failure do
    it "considers two failures with same msg equal" do
      expect(Failure.new("foo")).to eql(Failure.new("foo"))
    end

    it "uses just the msg if the path is empty" do
      failure = Failure.new("expected string")
      expect(failure.to_s).to eql("expected string")
    end

    it "prefixes error message with path segments" do
      failure = Failure.new("expected string").push("0").push("foo")
      expect(failure.to_s).to eql("Error at .foo.0: expected string")
    end

    it "transforms the message" do
      failure = Failure.new("expected string").map(&:upcase)
      expect(failure.to_s).to eql("EXPECTED STRING")
    end

    it "retains the path when transforming the message" do
      failure = Failure.new("expected string").push("0").push("foo").map { "expected integer" }
      expect(failure.to_s).to eql("Error at .foo.0: expected integer")
    end
  end
end
