# frozen_string_literal: true

require_relative "../../../lib/decoding/decoders"
require_relative "../../../lib/decoding/decoders/enum"
require_relative "../../../lib/decoding/result"

module Decoding
  module Decoders
    RSpec.describe Enum do
      it "decodes a value that is one of the given values" do
        expect(Enum.new("active", "archived")).to decode_value("active").to("active")
      end

      it "fails for a value that is not one of the given values" do
        expect(Enum.new("active", "archived"))
          .to decode_value("nope").failing_with(%(expected one of "active", "archived", got "nope"))
      end

      it "takes the given values from a single array" do
        expect(Enum.new(%w[active archived])).to decode_value("archived").to("archived")
      end

      it "decodes values of any type" do
        expect(Enum.new(:a, 1, nil)).to decode_value(nil).to(nil)
        expect(Enum.new(:a, 1, nil)).to decode_value("a").failing_with(%(expected one of :a, 1, nil, got "a"))
      end

      it "compares values for equality rather than by pattern" do
        expect(Enum.new(String)).not_to decode_value("foo")
      end

      it "reports where in a nested structure the error occurred" do
        decoder = Decoders.field("status", Enum.new("active", "archived"))
        expect(decoder)
          .to decode_value({ "status" => "nope" })
          .failing_with(%(expected one of "active", "archived", got "nope")).at("status")
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
