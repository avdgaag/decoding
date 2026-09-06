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
  end
end
