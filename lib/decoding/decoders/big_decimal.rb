# frozen_string_literal: true

require "bigdecimal"

module Decoding
  # Decoders are composable functions for deconstructing unknown input values
  # into known output values.
  module Decoders
    # Matches the values {big_decimal} converts, in one check rather than
    # trying a decoder for each type and discarding their failures.
    DECIMAL_SOURCES = [::BigDecimal, ::Integer, ::Float, ::String].freeze
    DECIMAL_SOURCE = ->(value) { DECIMAL_SOURCES.any? { _1 === value } }
    private_constant :DECIMAL_SOURCES, :DECIMAL_SOURCE

    module_function

    # Decode a `BigDecimal` object, or a number or string describing one.
    #
    # Only finite numbers are accepted: `NaN` and `Infinity` are errors, as a
    # decimal is usually reached for when a value has to be exact.
    #
    # Note this decoder needs the `bigdecimal` gem, which is no longer part of
    # Ruby's default gems. Add it to your Gemfile to use this decoder.
    #
    # @example
    #   decode(big_decimal, "1.23") # => Decoding::Ok(BigDecimal("1.23"))
    #   decode(big_decimal, 42) # => Decoding::Ok(BigDecimal("42"))
    #   decode(big_decimal, "abc")
    #   # => Decoding::Err(%(expected a decimal number, got "abc"))
    # @return [Decoding::Decoder<BigDecimal>]
    # @see Decoding::Decoders::MapErr
    def big_decimal
      Decoders.map_err(
        Decoders.map(Decoders.match(DECIMAL_SOURCE)) do |value|
          BigDecimal(value).tap { |number| raise ArgumentError, "not a finite number" unless number.finite? }
        end
      ) { |_message, value| "expected a decimal number, got #{value.inspect}" }
    end
  end
end
