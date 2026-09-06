# frozen_string_literal: true

require_relative "../decoder"

module Decoding
  module Decoders
    # A decoder for a value that must be one of a fixed set of values.
    #
    # Values are compared for equality, not with the `===` operator the {Match}
    # decoder uses, so the values are read as themselves rather than as
    # patterns.
    #
    # @see Decoding::Decoders.enum
    class Enum < Decoder
      # @overload initialize(value, *values)
      #   @param value [Object]
      #   @param values [Object]
      # @overload initialize(values)
      #   @param values [Array<Object>] the values as a single array
      # @raise [ArgumentError] when no values are given, or one is repeated.
      def initialize(value, *values)
        @values = collect(value, values)
        super()
      end

      # @param value [Object]
      # @return [Decoding::Result<Object>]
      def call(value)
        return ok(value) if @values.include?(value)

        err(failure("expected one of #{@values.map(&:inspect).join(", ")}, got #{value.inspect}"))
      end

      private

      def collect(value, values)
        values = (values.empty? && value.is_a?(::Array) ? value.dup : [value, *values]).freeze
        raise ArgumentError, "expected at least one value to decode" if values.empty?

        duplicates = values.tally.select { |_, count| count > 1 }.keys
        raise ArgumentError, "duplicate values: #{duplicates.map(&:inspect).join(", ")}" if duplicates.any?

        values
      end
    end
  end
end
