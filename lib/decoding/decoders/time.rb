# frozen_string_literal: true

require "time"

module Decoding
  # Decoders are composable functions for deconstructing unknown input values
  # into known output values.
  module Decoders
    # The standard formats {Decoding::Decoders.time} can parse, each named after
    # the `Time` method that parses it.
    TIME_FORMATS = %i[iso8601 xmlschema rfc2822 rfc822 httpdate parse].freeze

    # The units {Decoding::Decoders.unix_time} can read a timestamp in, mapped
    # to the number of them that make up a second.
    UNIX_TIME_UNITS = { seconds: 1, milliseconds: 1000 }.freeze

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

    # Decode a unix timestamp, given as a number or as a string describing one.
    #
    # Timestamps are read as a number of seconds since the epoch unless another
    # unit is given. Note that reading a timestamp in the wrong unit is not an
    # error but a wildly different point in time, so a source that reports
    # milliseconds has to say so.
    #
    # @example
    #   decode(unix_time, 1_595_674_680) # => Decoding::Ok(2020-07-25 10:58:00 UTC)
    #   decode(unix_time(:milliseconds), 1_595_674_680_123)
    #   # => Decoding::Ok(2020-07-25 10:58:00.123 UTC)
    # @param unit [Symbol] one of the keys of {UNIX_TIME_UNITS}.
    # @raise [ArgumentError] when the unit is not a known one. This is raised
    #   when the decoder is built, not when it is used.
    # @return [Decoding::Decoder<Time>]
    # @see Decoding::Decoders::MapErr
    def unix_time(unit = :seconds)
      raise ArgumentError, "unknown unit: #{unit.inspect}" unless UNIX_TIME_UNITS.key?(unit)

      per_second = UNIX_TIME_UNITS.fetch(unit)
      Decoders.map_err(
        Decoders.any(
          Decoders.match(::Time),
          Decoders.map(
            Decoders.any(Decoders.integer, Decoders.float, Decoders.parsed_integer, Decoders.parsed_float)
          ) { ::Time.at(per_second == 1 ? _1 : _1 / Rational(per_second)) }
        )
      ) { |_message, value| "expected a unix timestamp, got #{value.inspect}" }
    end

    private_class_method :time_format
  end
end
