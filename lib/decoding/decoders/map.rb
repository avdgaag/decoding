# frozen_string_literal: true

require_relative "../decoder"

module Decoding
  module Decoders
    # A decoder that decodes a value and then applies a transformation to it, if
    # successful.
    class Map < Decoder
      # @param decoder [Decoding::Decoder<a>]
      # @yieldparam value [a]
      # @yieldreturn result [b]
      def initialize(decoder, &block)
        @decoder = decoder.to_decoder
        @block = block
        super()
      end

      # @param value [Object]
      # @return [Decoding::Result<b>]
      def call(value)
        @decoder.call(value).map(&@block)
      end
    end
  end
end
