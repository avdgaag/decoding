# frozen_string_literal: true

require_relative "../decoder"

module Decoding
  module Decoders
    # Decode a value in deeply nested hashes.
    #
    # @see Decoding::Decoders.field
    class At < Decoder
      # @param keys [Array<Object>]
      # @param decoder [Decoding::Decoder<a>]
      def initialize(*keys, decoder)
        @keys = keys.to_a
        @decoder = decoder.to_decoder
        super()
      end

      # @param value [Object]
      # @return [Decoding::Result<a>]
      def call(value)
        first, *rest = @keys.reverse
        nested_decoder = rest.reduce(Decoders::Field.new(first, @decoder)) do |acc, k|
          Decoders::Field.new(k, acc)
        end
        nested_decoder.call(value)
      end
    end
  end
end
