# frozen_string_literal: true

require "time"

module Decoding
  # Decoders are composable functions for deconstructing unknown input values
  # into known output values.
  module Decoders
    # The standard formats {Decoding::Decoders.time} can parse, each named after
    # the `Time` method that parses it.
    TIME_FORMATS = %i[iso8601 xmlschema rfc2822 rfc822 httpdate parse].freeze

    module_function

    # Decode a `Time` object, or a string describing a time in a given format.
    #
    # The format is either the name of one of {TIME_FORMATS}, or a string with a
    # `strptime` pattern. Note that the `:parse` format is lenient: it fills in
    # any components the input value leaves out from the current time.
    #
    # @example
    #   decode(time(:iso8601), "2020-01-01T10:00:00Z")
    #   # => Decoding::Ok(2020-01-01 10:00:00 UTC)
    #   decode(time("%Y|%m"), "nope")
    #   # => Decoding::Err("expected a time matching \"%Y|%m\", got \"nope\"")
    # @param format [Symbol, String]
    # @raise [ArgumentError] when the format is not a known name or a pattern.
    #   This is raised when the decoder is built, not when it is used.
    # @return [Decoding::Decoder<Time>]
    # @see Decoding::Decoders::MapErr
    def time(format)
      parse, description = time_format(format)
      Decoders.map_err(
        Decoders.any(
          Decoders.match(::Time),
          Decoders.map(Decoders.string) { parse.call(_1) }
        )
      ) { |_message, value| "expected #{description}, got #{value.inspect}" }
    end

    # @private
    def time_format(format)
      case format
      when ::String
        [->(str) { ::Time.strptime(str, format) }, "a time matching #{format.inspect}"]
      when ::Symbol
        raise ArgumentError, "unknown time format: #{format.inspect}" unless TIME_FORMATS.include?(format)

        [->(str) { ::Time.public_send(format, str) }, format == :parse ? "a time" : "a time in #{format} format"]
      else
        raise ArgumentError, "expected a time format name or a strptime pattern, got #{format.inspect}"
      end
    end

    private_class_method :time_format
  end
end
