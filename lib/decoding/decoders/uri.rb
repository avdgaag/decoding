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
          Decoders::Match.new(::URI::Generic),
          Decoders.map(Decoders.string) { ::URI.parse(_1) }
        )
      ) { |_msg, value| "expected a URI, got #{value.inspect}" }
    end
  end
end
