# frozen_string_literal: true

require_relative "../../../lib/decoding/decoders"
require_relative "../../../lib/decoding/decoders/date"
require_relative "../../../lib/decoding/result"

module Decoding
  RSpec.describe Decoders do
    it "parses a string in a named format" do
      Decoding.decode(Decoders.date(:iso8601), "2020-01-01") => Decoding::Ok(date)
      expect(date).to eql(Date.new(2020, 1, 1))
    end

    it "parses a string in a format only dates support" do
      Decoding.decode(Decoders.date(:rfc3339), "2020-01-01T00:00:00+00:00") => Decoding::Ok(date)
      expect(date).to eql(Date.new(2020, 1, 1))
    end

    it "passes through Date objects" do
      date = Date.new(2020, 1, 1)
      Decoding.decode(Decoders.date(:iso8601), date) => Decoding::Ok(result)
      expect(result).to eql(date)
    end

    it "parses a string using a strptime pattern" do
      Decoding.decode(Decoders.date("%Y|%m"), "2020|01") => Decoding::Ok(date)
      expect(date).to eql(Date.new(2020, 1, 1))
    end

    it "parses a string leniently with the parse format" do
      Decoding.decode(Decoders.date(:parse), "1st Feb 2020") => Decoding::Ok(date)
      expect(date).to eql(Date.new(2020, 2, 1))
    end

    it "names the format it expected when parsing fails" do
      Decoding.decode(Decoders.date(:iso8601), "nope") => Decoding::Err(msg)
      expect(msg).to eql('expected a date in iso8601 format, got "nope"')
    end

    it "names the pattern it expected when parsing fails" do
      Decoding.decode(Decoders.date("%Y|%m"), "nope") => Decoding::Err(msg)
      expect(msg).to eql('expected a date matching "%Y|%m", got "nope"')
    end

    it "names no format when the parse format fails" do
      Decoding.decode(Decoders.date(:parse), 123) => Decoding::Err(msg)
      expect(msg).to eql("expected a date, got 123")
    end

    it "reports where in a nested structure the error occurred" do
      decoder = Decoders.field("on", Decoders.date(:iso8601))
      Decoding.decode(decoder, { "on" => "nope" }) => Decoding::Err(msg)
      expect(msg).to eql('Error at .on: expected a date in iso8601 format, got "nope"')
    end

    it "refuses an unknown format name" do
      expect { Decoders.date(:bogus) }.to raise_error(ArgumentError, /unknown date format: :bogus/)
    end

    it "refuses a format that is neither a name nor a pattern" do
      expect { Decoders.date(123) }.to raise_error(ArgumentError, /got 123/)
    end
  end
end
