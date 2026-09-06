# frozen_string_literal: true

require_relative "../../../lib/decoding/decoders"
require_relative "../../../lib/decoding/decoders/uri"
require_relative "../../../lib/decoding/result"

module Decoding
  RSpec.describe Decoders do
    it "parses a valid URI string" do
      Decoding.decode(Decoders.uri, "https://example.com") => Decoding::Ok(uri)
      expect(uri).to eql(URI("https://example.com"))
    end

    it "passes through URI objects" do
      uri = URI("http://example.com")
      Decoding.decode(Decoders.uri, uri) => Decoding::Ok(result)
      expect(result).to eql(uri)
    end

    it "fails given something other than a string" do
      Decoding.decode(Decoders.uri, 123) => Decoding::Err(msg)
      expect(msg.to_s).to eql("expected a URI, got 123")
    end

    it "fails given a string that cannot be parsed" do
      Decoding.decode(Decoders.uri, "not a uri at all") => Decoding::Err(msg)
      expect(msg.to_s).to eql('expected a URI, got "not a uri at all"')
    end

    it "reports where in a nested structure the error occurred" do
      decoder = Decoders.field("website", Decoders.uri)
      Decoding.decode(decoder, { "website" => 123 }) => Decoding::Err(msg)
      expect(msg.to_s).to eql("Error at .website: expected a URI, got 123")
    end
  end
end
