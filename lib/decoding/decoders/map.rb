# frozen_string_literal: true

require_relative "../decoder"

module Decoding
  module Decoders
    # A decoder that decodes a value and then applies a transformation to it, if
    # successful.
    #
    # @see Decoding::Decoders.map
    class Map < Decoder
      # @param decoder [Decoding::Decoder<a>]
      # @yieldparam value [a]
      # @yieldreturn [b]
      def initialize(decoder, *rest, &block)
        @decoders = [decoder, *rest].map(&:to_decoder)
        @block = block
        super()
      end

      # @param value [Object]
      # @return [Decoding::Result<b>]
      def call(value)
        Result
          .all(@decoders.map { _1.call(value) })
          .map { @block.call(*_1) }
      rescue StandardError => e
        err(failure("error in map block: #{e.message}"))
      end
    end
  end
end
