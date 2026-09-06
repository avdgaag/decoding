# frozen_string_literal: true

require "date"

module Decoding
  # Decoders are composable functions for deconstructing unknown input values
  # into known output values.
  module Decoders
    # The standard formats {Decoding::Decoders.date} can parse, each named after
    # the `Date` method that parses it.
    DATE_FORMATS = %i[iso8601 xmlschema rfc2822 rfc822 rfc3339 httpdate jisx0301 parse].freeze

    module_function

    # Decode a `Date` object, or a string describing a date in a given format.
    #
    # The format is either the name of one of {DATE_FORMATS}, or a string with a
    # `strptime` pattern. Note that the `:parse` format is lenient: it fills in
    # any components the input value leaves out from the current date.
    #
    # @example
    #   decode(date(:iso8601), "2020-01-01")
    #   # => Decoding::Ok(#<Date: 2020-01-01>)
    #   decode(date("%Y|%m"), "nope")
    #   # => Decoding::Err("expected a date matching \"%Y|%m\", got \"nope\"")
    # @param format [Symbol, String]
    # @raise [ArgumentError] when the format is not a known name or a pattern.
    #   This is raised when the decoder is built, not when it is used.
    # @return [Decoding::Decoder<Date>]
    # @see Decoding::Decoders::MapErr
    def date(format)
      parse, description = date_format(format)
      Decoders.map_err(
        Decoders.any(
          Decoders.match(::Date),
          Decoders.map(Decoders.string) { parse.call(_1) }
        )
      ) { |_message, value| "expected #{description}, got #{value.inspect}" }
    end

    # @private
    def date_format(format)
      case format
      when ::String
        [->(str) { ::Date.strptime(str, format) }, "a date matching #{format.inspect}"]
      when ::Symbol
        raise ArgumentError, "unknown date format: #{format.inspect}" unless DATE_FORMATS.include?(format)

        [->(str) { ::Date.public_send(format, str) }, format == :parse ? "a date" : "a date in #{format} format"]
      else
        raise ArgumentError, "expected a date format name or a strptime pattern, got #{format.inspect}"
      end
    end

    private_class_method :date_format
  end
end
