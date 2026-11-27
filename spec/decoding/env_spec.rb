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

    it "raises when the value cannot be decoded, naming the variable but not its value" do
      expect { Decoding.env("PORT", :integer, from: { "PORT" => "abc" }) }
        .to raise_error(Decoding::UnwrapError, 'ENV["PORT"]: expected an integer, got [REDACTED]')
    end

    it "keeps a secret in the value out of the error" do
      value = "htps://user:s3cret@example.com/list?token=abc123"

      expect { Decoding.env("LIST_URL", Decoders.http_url, from: { "LIST_URL" => value }) }
        .to raise_error(Decoding::UnwrapError, 'ENV["LIST_URL"]: expected an http(s) URL, got [REDACTED]')
    end

    it "leaves out the message of a decoder that shows the value other than inspected" do
      decoder = Decoders.and_then(Decoders.string) { |s| Decoders.fail("no idea what #{s} means") }

      expect { Decoding.env("MODE", decoder, from: { "MODE" => "s3cret" }) }
        .to raise_error(Decoding::UnwrapError, 'ENV["MODE"]: cannot be decoded; the value is not shown')
    end

    it "leaves out the message of a decoder that shows only part of the value" do
      decoder = Decoders.and_then(Decoders.string) { |s| Decoders.fail("unknown token #{s.split("=").last}") }

      expect { Decoding.env("LIST_URL", decoder, from: { "LIST_URL" => "https://example.com/?token=s3cret" }) }
        .to raise_error(Decoding::UnwrapError, 'ENV["LIST_URL"]: cannot be decoded; the value is not shown')
    end

    it "leaves out a message of the built-in form that shows the value in its description too" do
      decoder = Decoders.and_then(Decoders.string) { |s| Decoders.fail("expected not #{s}, got #{s.inspect}") }

      expect { Decoding.env("MODE", decoder, from: { "MODE" => "s3cret" }) }
        .to raise_error(Decoding::UnwrapError, 'ENV["MODE"]: cannot be decoded; the value is not shown')
    end

    it "leaves out a message whose description shows the value escaped" do
      decoder = Decoders.and_then(Decoders.string) { |s| Decoders.fail("expected not #{s.inspect[1..-2]}, got #{s.inspect}") }

      expect { Decoding.env("MODE", decoder, from: { "MODE" => "s3\"cret" }) }
        .to raise_error(Decoding::UnwrapError, 'ENV["MODE"]: cannot be decoded; the value is not shown')
    end

    it "leaves out a message that names the value's class rather than the value" do
      expect { Decoding.env("DEBUG", Decoders.boolean, from: { "DEBUG" => "yes" }) }
        .to raise_error(Decoding::UnwrapError, 'ENV["DEBUG"]: cannot be decoded; the value is not shown')
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
