# frozen_string_literal: true

require_relative "../../../lib/decoding/decoders"
require_relative "../../../lib/decoding/decoders/date"
require_relative "../../../lib/decoding/result"

module Decoding
  RSpec.describe Decoders do
    it "parses a string in a named format" do
      expect(Decoders.date(:iso8601)).to decode_value("2020-01-01").to(Date.new(2020, 1, 1))
    end

    it "parses a string in a format only dates support" do
      expect(Decoders.date(:rfc3339)).to decode_value("2020-01-01T00:00:00+00:00").to(Date.new(2020, 1, 1))
    end

    it "passes through Date objects" do
      date = Date.new(2020, 1, 1)
      expect(Decoders.date(:iso8601)).to decode_value(date).to(date)
    end

    it "parses a string using a strptime pattern" do
      expect(Decoders.date("%Y|%m")).to decode_value("2020|01").to(Date.new(2020, 1, 1))
    end

    it "parses a string leniently with the parse format" do
      expect(Decoders.date(:parse)).to decode_value("1st Feb 2020").to(Date.new(2020, 2, 1))
    end

    it "names the format it expected when parsing fails" do
      expect(Decoders.date(:iso8601)).to decode_value("nope").failing_with('expected a date in iso8601 format, got "nope"')
    end

    it "names the pattern it expected when parsing fails" do
      expect(Decoders.date("%Y|%m")).to decode_value("nope").failing_with('expected a date matching "%Y|%m", got "nope"')
    end

    it "names no format when the parse format fails" do
      expect(Decoders.date(:parse)).to decode_value(123).failing_with("expected a date, got 123")
    end

    it "reports where in a nested structure the error occurred" do
      expect(Decoders.field("on", Decoders.date(:iso8601)))
        .to decode_value({ "on" => "nope" }).failing_with('expected a date in iso8601 format, got "nope"').at("on")
    end

    it "refuses an unknown format name" do
      expect { Decoders.date(:bogus) }.to raise_error(ArgumentError, /unknown date format: :bogus/)
    end

    it "refuses a format that is neither a name nor a pattern" do
      expect { Decoders.date(123) }.to raise_error(ArgumentError, /got 123/)
    end
  end
end
