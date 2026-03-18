# frozen_string_literal: true

require_relative "../result"
require_relative "../decoder"

module Decoding
  module Decoders
    # A decoder wrapping any number of decoders, finding the first one that
    # matches the given value and returning its result.
    #
    # @see Decoding::Decoders.any
    class Any < Decoder
      # @param decoder [Decoding::Decoder<Object>]
      # @param decoders [Decoding::Decoder<Object>]
      def initialize(decoder, *decoders)
        @decoders = [decoder, *decoders].map(&:to_decoder)
        super()
      end

      # @param value [Object]
      # @return [Decoding::Result<Object>]
      def call(value)
        failures = []
        @decoders.each do |decoder|
          result = decoder.call(value)

          # NOTE: we could've pattern matched here but that would create an
          # unreachable `else` clause triggering code coverage issues. This
          # explicit way ensures we know every code path is touched.
          return result if result.ok?

          failures << result.unwrap_err(nil)
        end
        err(failure("None of the decoders matched:\n#{failures.map { "  - #{_1}" }.join("\n")}"))
      end
    end
  end
end
