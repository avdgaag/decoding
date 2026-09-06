# frozen_string_literal: true

require_relative "../../../lib/decoding/decoders"
require_relative "../../../lib/decoding/decoders/time"
require_relative "../../../lib/decoding/result"

module Decoding
  RSpec.describe Decoders do
    it "parses a string in a named format" do
      expect(Decoders.time(:iso8601)).to decode_value("2020-01-01T10:00:00Z").to(Time.utc(2020, 1, 1, 10, 0, 0))
    end

    it "passes through Time objects" do
      time = Time.utc(2020, 1, 1)
      expect(Decoders.time(:iso8601)).to decode_value(time).to(time)
    end

    it "parses a string using a strptime pattern" do
      expect(Decoders.time("%Y|%m")).to decode_value("2020|01").to(Time.local(2020, 1, 1))
    end

    it "parses a string leniently with the parse format" do
      expect(Decoders.time(:parse)).to decode_value("2020-01-01 10:00:00 UTC").to(Time.utc(2020, 1, 1, 10, 0, 0))
    end

    it "names the format it expected when parsing fails" do
      expect(Decoders.time(:iso8601)).to decode_value("3rd Feb").failing_with('expected a time in iso8601 format, got "3rd Feb"')
    end

    it "names the pattern it expected when parsing fails" do
      expect(Decoders.time("%Y|%m")).to decode_value("nope").failing_with('expected a time matching "%Y|%m", got "nope"')
    end

    it "names no format when the parse format fails" do
      expect(Decoders.time(:parse)).to decode_value(123).failing_with("expected a time, got 123")
    end

    it "reports where in a nested structure the error occurred" do
      expect(Decoders.field("at", Decoders.time(:iso8601)))
        .to decode_value({ "at" => "nope" }).failing_with('expected a time in iso8601 format, got "nope"').at("at")
    end

    it "decodes a unix timestamp given as an integer" do
      expect(Decoders.unix_time).to decode_value(1_595_674_680).to(Time.utc(2020, 7, 25, 10, 58, 0))
    end

    it "decodes a unix timestamp given as a string" do
      expect(Decoders.unix_time).to decode_value("1595674680").to(Time.utc(2020, 7, 25, 10, 58, 0))
    end

    it "decodes a unix timestamp with a fractional number of seconds" do
      expect(Decoders.unix_time).to decode_value("1595674680.5").to(an_object_having_attributes(usec: 500_000))
    end

    it "decodes a unix timestamp in milliseconds" do
      expect(Decoders.unix_time(:milliseconds))
        .to decode_value(1_595_674_680_123).to(Time.utc(2020, 7, 25, 10, 58, 0) + Rational(123, 1000))
    end

    it "passes through Time objects given a unix timestamp" do
      time = Time.utc(2020, 1, 1)
      expect(Decoders.unix_time).to decode_value(time).to(time)
    end

    it "fails given something that is not a unix timestamp" do
      expect(Decoders.unix_time).to decode_value("abc").failing_with(%(expected a unix timestamp, got "abc"))
      expect(Decoders.unix_time).to decode_value(nil).failing_with("expected a unix timestamp, got nil")
    end

    it "fails given a number that cannot be a point in time" do
      expect(Decoders.unix_time).to decode_value(Float::NAN).failing_with("expected a unix timestamp, got NaN")
    end

    it "refuses an unknown unit" do
      expect { Decoders.unix_time(:furlongs) }.to raise_error(ArgumentError, /unknown unit: :furlongs/)
    end

    it "refuses an unknown format name" do
      expect { Decoders.time(:bogus) }.to raise_error(ArgumentError, /unknown time format: :bogus/)
    end

    it "refuses a format that is neither a name nor a pattern" do
      expect { Decoders.time(123) }.to raise_error(ArgumentError, /got 123/)
    end
  end
end
