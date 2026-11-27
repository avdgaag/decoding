# frozen_string_literal: true

require "uri"

module Decoding
  # Decoders are composable functions for deconstructing unknown input values
  # into known output values.
  module Decoders
    module_function

    # Decode a URI object, or a string that can be parsed as one.
    #
    # @example
    #   decode(uri, "https://example.com") # => Decoding::Ok(URI("https://example.com"))
    #   decode(uri, 123) # => Decoding::Err("expected a URI, got 123")
    # @return [Decoding::Decoder<URI::Generic>]
    # @see Decoding::Decoders::MapErr
    def uri
      Decoders.map_err(
        Decoders.any(
          Decoders.map(Decoders.string) { ::URI.parse(_1) },
          Decoders::Match.new(::URI::Generic)
        )
      ) { |_msg, value| "expected a URI, got #{value.inspect}" }
    end

    # Decode an absolute http or https URL into a string: a URI object, or a
    # string that can be parsed as one, with an http or https scheme and a host.
    #
    # Stricter than {uri}, which also accepts an empty string and a host without
    # a scheme. That makes it the one to read a URL from the environment with,
    # where a mistyped value should stop the application from starting.
    #
    # @example
    #   decode(http_url, "https://example.com") # => Decoding::Ok("https://example.com")
    #   decode(http_url, "example.com") # => Decoding::Err("expected an http(s) URL, got \"example.com\"")
    # @return [Decoding::Decoder<String>]
    # @see Decoding::Decoders.uri
    def http_url
      Decoders.map_err(
        Decoders.and_then(uri) do |parsed|
          if parsed.is_a?(::URI::HTTP) && !parsed.host.to_s.empty?
            Decoders.succeed(parsed.to_s)
          else
            Decoders.fail("expected an http or https scheme and a host")
          end
        end
      ) { |_msg, value| "expected an http(s) URL, got #{value.inspect}" }
    end
  end
end
