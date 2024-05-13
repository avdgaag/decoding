# frozen_string_literal: true

require_relative "../result"
require_relative "../decoder"

module Decoding
  module Decoders
    # Decode the element at a specific offset in an array.
    #
    # @see Decoding::Decoders.index
    class Index < Decoder
      # @private
      Err = Result.err("error decoding array: index is out of bounds")

      # @param index [Integer]
      # @param decoder [Decoding::Decoder<Object>]
      def initialize(index, decoder)
        @index = index.to_int
        @decoder = decoder.to_decoder
        super()
      end

      # @param value [Object]
      # @return [Decoding::Decoder<Object>]
      def call(value)
        return err("expected an Array, got: #{value.class}") unless value.is_a?(::Array)

        @decoder
          .call(value.fetch(@index))
          .map_err { "error decoding array item #{@index}: #{_1}" }
      rescue IndexError => e
        err("error decoding array: #{e}")
      end
    end
  end
end
