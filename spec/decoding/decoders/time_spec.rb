# frozen_string_literal: true

require_relative "../../../lib/decoding/decoders"
require_relative "../../../lib/decoding/decoders/time"
require_relative "../../../lib/decoding/result"

module Decoding
  RSpec.describe Decoders do
    it "parses a string in a named format" do
      Decoding.decode(Decoders.time(:iso8601), "2020-01-01T10:00:00Z") => Decoding::Ok(time)
      expect(time).to eql(Time.utc(2020, 1, 1, 10, 0, 0))
    end

    it "passes through Time objects" do
      time = Time.utc(2020, 1, 1)
      Decoding.decode(Decoders.time(:iso8601), time) => Decoding::Ok(result)
      expect(result).to eql(time)
    end

    it "parses a string using a strptime pattern" do
      Decoding.decode(Decoders.time("%Y|%m"), "2020|01") => Decoding::Ok(time)
      expect(time).to eql(Time.local(2020, 1, 1))
    end

    it "parses a string leniently with the parse format" do
      Decoding.decode(Decoders.time(:parse), "2020-01-01 10:00:00 UTC") => Decoding::Ok(time)
      expect(time).to eql(Time.utc(2020, 1, 1, 10, 0, 0))
    end

    it "names the format it expected when parsing fails" do
      Decoding.decode(Decoders.time(:iso8601), "3rd Feb") => Decoding::Err(msg)
      expect(msg).to eql('expected a time in iso8601 format, got "3rd Feb"')
    end

    it "names the pattern it expected when parsing fails" do
      Decoding.decode(Decoders.time("%Y|%m"), "nope") => Decoding::Err(msg)
      expect(msg).to eql('expected a time matching "%Y|%m", got "nope"')
    end

    it "names no format when the parse format fails" do
      Decoding.decode(Decoders.time(:parse), 123) => Decoding::Err(msg)
      expect(msg).to eql("expected a time, got 123")
    end

    it "reports where in a nested structure the error occurred" do
      decoder = Decoders.field("at", Decoders.time(:iso8601))
      Decoding.decode(decoder, { "at" => "nope" }) => Decoding::Err(msg)
      expect(msg).to eql('Error at .at: expected a time in iso8601 format, got "nope"')
    end

    it "refuses an unknown format name" do
      expect { Decoders.time(:bogus) }.to raise_error(ArgumentError, /unknown time format: :bogus/)
    end

    it "refuses a format that is neither a name nor a pattern" do
      expect { Decoders.time(123) }.to raise_error(ArgumentError, /got 123/)
    end
  end
end
