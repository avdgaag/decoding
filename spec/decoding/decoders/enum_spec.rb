# frozen_string_literal: true

require_relative "../../../lib/decoding/decoders"
require_relative "../../../lib/decoding/decoders/enum"
require_relative "../../../lib/decoding/result"

module Decoding
  module Decoders
    RSpec.describe Enum do
      it "decodes a value that is one of the given values" do
        expect(Enum.new("active", "archived").call("active")).to eql(Result.ok("active"))
      end

      it "fails for a value that is not one of the given values" do
        expect(Decoding.decode(Enum.new("active", "archived"), "nope"))
          .to eql(Result.err(%(expected one of "active", "archived", got "nope")))
      end

      it "takes the given values from a single array" do
        expect(Enum.new(%w[active archived]).call("archived")).to eql(Result.ok("archived"))
      end

      it "decodes values of any type" do
        expect(Enum.new(:a, 1, nil).call(nil)).to eql(Result.ok(nil))
        expect(Decoding.decode(Enum.new(:a, 1, nil), "a"))
          .to eql(Result.err(%(expected one of :a, 1, nil, got "a")))
      end

      it "compares values for equality rather than by pattern" do
        expect(Decoding.decode(Enum.new(String), "foo")).to be_err
      end

      it "reports where in a nested structure the error occurred" do
        decoder = Decoders.field("status", Enum.new("active", "archived"))
        expect(Decoding.decode(decoder, { "status" => "nope" }))
          .to eql(Result.err(%(Error at .status: expected one of "active", "archived", got "nope")))
      end

      it "refuses duplicate values" do
        expect { Enum.new("active", "archived", "active") }
          .to raise_error(ArgumentError, /duplicate values: "active"/)
      end

      it "refuses an empty list of values" do
        expect { Enum.new([]) }.to raise_error(ArgumentError, /at least one value/)
      end
    end
  end
end
