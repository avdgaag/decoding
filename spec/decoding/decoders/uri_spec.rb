# frozen_string_literal: true

require_relative "../../../lib/decoding/decoders"
require_relative "../../../lib/decoding/decoders/uri"
require_relative "../../../lib/decoding/result"

module Decoding
  RSpec.describe Decoders do
    subject(:decoder) { Decoders.uri }

    it "parses a valid URI string" do
      expect(decoder).to decode_value("https://example.com").to(URI("https://example.com"))
    end

    it "passes through URI objects" do
      uri = URI("http://example.com")
      expect(decoder).to decode_value(uri).to(uri)
    end

    it "fails given something other than a string" do
      expect(decoder).to decode_value(123).failing_with("expected a URI, got 123")
    end

    it "fails given a string that cannot be parsed" do
      expect(decoder).to decode_value("not a uri at all").failing_with('expected a URI, got "not a uri at all"')
    end

    it "reports where in a nested structure the error occurred" do
      expect(Decoders.field("website", decoder))
        .to decode_value({ "website" => 123 }).failing_with("expected a URI, got 123").at("website")
    end

    describe ".http_url" do
      subject(:decoder) { Decoders.http_url }

      it "decodes an https URL string to the same string" do
        expect(decoder).to decode_value("https://example.com/path?q=1").to("https://example.com/path?q=1")
      end

      it "decodes an http URL string" do
        expect(decoder).to decode_value("http://example.com").to("http://example.com")
      end

      it "decodes an http URI object to a string" do
        expect(decoder).to decode_value(URI("https://example.com")).to("https://example.com")
      end

      it "fails given an empty string, which uri accepts" do
        expect(decoder).to decode_value("").failing_with(%(expected an http(s) URL, got ""))
      end

      it "fails given a host without a scheme, which uri accepts" do
        expect(decoder).to decode_value("example.com").failing_with(%(expected an http(s) URL, got "example.com"))
      end

      it "fails given a scheme other than http or https" do
        expect(decoder).to decode_value("postgres://localhost/app").failing_with(%(expected an http(s) URL, got "postgres://localhost/app"))
      end

      it "fails given a URL without a host" do
        expect(decoder).to decode_value("https://").failing_with(%(expected an http(s) URL, got "https://"))
      end

      it "fails given a string that cannot be parsed" do
        expect(decoder).to decode_value("https://example.com ").failing_with(%(expected an http(s) URL, got "https://example.com "))
      end

      it "fails given something other than a string or URI" do
        expect(decoder).to decode_value(nil).failing_with("expected an http(s) URL, got nil")
      end

      it "reports where in a nested structure the error occurred" do
        expect(Decoders.field("website", decoder))
          .to decode_value({ "website" => "example.com" }).failing_with(%(expected an http(s) URL, got "example.com")).at("website")
      end
    end
  end
end
