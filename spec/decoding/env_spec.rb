# frozen_string_literal: true

require_relative "../../lib/decoding"
require_relative "../../lib/decoding/env"
require_relative "../../lib/decoding/decoders/uri"

module Decoding
  RSpec.describe Decoding do
    it "reads a variable as a string by default" do
      expect(Decoding.env("HOST", from: { "HOST" => "example.com" })).to eql("example.com")
    end

    it "reads a variable using a named type" do
      expect(Decoding.env("PORT", :integer, from: { "PORT" => "8080" })).to be(8080)
      expect(Decoding.env("DEBUG", :boolean, from: { "DEBUG" => "true" })).to be(true)
      expect(Decoding.env("LEVEL", :symbol, from: { "LEVEL" => "warn" })).to be(:warn)
      expect(Decoding.env("RATE", :float, from: { "RATE" => "1.5" })).to be(1.5)
    end

    it "reads a variable using any given decoder" do
      uri = Decoding.env("URL", Decoders.uri, from: { "URL" => "https://example.com" })
      expect(uri).to eql(URI("https://example.com"))
    end

    it "reads from ENV by default" do
      ENV["DECODING_SPEC_VAR"] = "here"
      expect(Decoding.env("DECODING_SPEC_VAR")).to eql("here")
    ensure
      ENV.delete("DECODING_SPEC_VAR")
    end

    it "raises when the variable is not set" do
      expect { Decoding.env("PORT", :integer, from: {}) }
        .to raise_error(Decoding::UnwrapError, 'ENV["PORT"] is not set')
    end

    it "raises when the value cannot be decoded, naming the variable" do
      expect { Decoding.env("PORT", :integer, from: { "PORT" => "abc" }) }
        .to raise_error(Decoding::UnwrapError, 'ENV["PORT"]: expected an integer, got "abc"')
    end

    it "returns the default when the variable is not set" do
      expect(Decoding.env("PORT", :integer, default: 3000, from: {})).to be(3000)
    end

    it "ignores the default when the variable is set" do
      expect(Decoding.env("PORT", :integer, default: 3000, from: { "PORT" => "8080" })).to be(8080)
    end

    it "treats an empty value as set, rather than falling back to the default" do
      expect { Decoding.env("PORT", :integer, default: 3000, from: { "PORT" => "" }) }
        .to raise_error(Decoding::UnwrapError, 'ENV["PORT"]: expected an integer, got ""')
    end

    it "returns nil for an unset variable given a decoder that accepts nil" do
      expect(Decoding.env("HOST", Decoders.optional(Decoders.string), from: {})).to be_nil
    end

    it "refuses an unknown type name" do
      expect { Decoding.env("PORT", :widget, from: {}) }
        .to raise_error(ArgumentError, /unknown type: :widget/)
    end

    it "refuses a type that is neither a name nor a decoder" do
      expect { Decoding.env("PORT", 123, from: {}) }
        .to raise_error(ArgumentError, /got 123/)
    end
  end
end
