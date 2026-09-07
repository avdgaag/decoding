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
    # Times are resolved by `Time` itself, and so in the system's time zone,
    # unless another zone is given. Anything answering the format you name will
    # do: an `ActiveSupport::TimeZone` resolves in the application's zone, which
    # is rarely the system's, but note it answers only `iso8601`, `rfc3339` and
    # `parse` of the names above.
    #
    # @example
    #   decode(time(:iso8601), "2020-01-01T10:00:00Z")
    #   # => Decoding::Ok(2020-01-01 10:00:00 UTC)
    #   decode(time("%Y|%m"), "nope")
    #   # => Decoding::Err("expected a time matching \"%Y|%m\", got \"nope\"")
    #   decode(time(:parse, zone: Time.zone), "2020-01-01 10:00:00")
    #   # => Decoding::Ok(2020-01-01 10:00:00 +0100)
    # @param format [Symbol, String]
    # @param zone [Object] anything answering the format you name, such as
    #   `Time` or an `ActiveSupport::TimeZone`.
    # @raise [ArgumentError] when the format is not a known name or a pattern,
    #   or the zone cannot parse it. This is raised when the decoder is built,
    #   not when it is used.
    # @return [Decoding::Decoder<Time>]
    # @see Decoding::Decoders::MapErr
    def time(format, zone: ::Time)
      parse, description = time_format(format, zone)
      Decoders.map_err(
        Decoders.any(
          Decoders.match(::Time),
          parsed_by(parse)
        )
      ) { |_message, value| "expected #{description}, got #{value.inspect}" }
    end

    # @private
    def time_format(format, zone)
      case format
      when ::String
        description = "a time matching #{format.inspect}"
        require_parser(zone, :strptime, description)
        [->(str) { zone.strptime(str, format) }, description]
      when ::Symbol
        raise ArgumentError, "unknown time format: #{format.inspect}" unless TIME_FORMATS.include?(format)

        description = format == :parse ? "a time" : "a time in #{format} format"
        require_parser(zone, format, description)
        [->(str) { zone.public_send(format, str) }, description]
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
    # A timestamp names a point in time rather than a local one, so the zone
    # only decides how the value describes itself afterwards -- which matters as
    # soon as anything derives a date from it.
    #
    # @example
    #   decode(unix_time, 1_595_674_680) # => Decoding::Ok(2020-07-25 10:58:00 UTC)
    #   decode(unix_time(:milliseconds), 1_595_674_680_123)
    #   # => Decoding::Ok(2020-07-25 10:58:00.123 UTC)
    # @param unit [Symbol] one of the keys of {UNIX_TIME_UNITS}.
    # @param zone [Object] anything answering `at`, such as `Time` or an
    #   `ActiveSupport::TimeZone`.
    # @raise [ArgumentError] when the unit is not a known one, or the zone
    #   cannot read a timestamp. This is raised when the decoder is built, not
    #   when it is used.
    # @return [Decoding::Decoder<Time>]
    # @see Decoding::Decoders::MapErr
    def unix_time(unit = :seconds, zone: ::Time)
      raise ArgumentError, "unknown unit: #{unit.inspect}" unless UNIX_TIME_UNITS.key?(unit)

      require_parser(zone, :at, "a unix timestamp")
      Decoders.map_err(
        Decoders.any(
          Decoders.match(::Time),
          timestamp_in(zone, UNIX_TIME_UNITS.fetch(unit))
        )
      ) { |_message, value| "expected a unix timestamp, got #{value.inspect}" }
    end

    # Decode a number, or a string describing one, as a point in time.
    #
    # @private
    def timestamp_in(zone, per_second)
      Decoders.map(
        Decoders.any(Decoders.integer, Decoders.float, Decoders.parsed_integer, Decoders.parsed_float)
      ) { zone.at(per_second == 1 ? _1 : _1 / Rational(per_second)) }
    end

    # Decode a string with the given parser, treating a nil answer as a failure.
    #
    # Every method of `Time` raises for a value it cannot parse, but
    # `ActiveSupport::TimeZone#parse` answers with nil instead, which would
    # otherwise decode as a successful nil.
    #
    # @private
    def parsed_by(parse)
      Decoders.and_then(Decoders.map(Decoders.string) { parse.call(_1) }) do |value|
        value.nil? ? Decoders.fail("parsed to nothing") : Decoders.succeed(value)
      end
    end

    # Refuse a zone that cannot answer the parsing this decoder will ask of it,
    # while the decoder is being built rather than once it is decoding.
    #
    # @private
    def require_parser(zone, method, description)
      return if zone.respond_to?(method)

      raise ArgumentError, "cannot decode #{description}: the given zone does not respond to #{method}"
    end

    private_class_method :time_format, :parsed_by, :timestamp_in, :require_parser
  end
end
