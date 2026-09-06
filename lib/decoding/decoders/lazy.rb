# frozen_string_literal: true

require_relative "../decoder"

module Decoding
  module Decoders
    # A decoder that builds the decoder it delegates to on first use, rather
    # than when it is created.
    #
    # This is what makes recursive decoders possible: a decoder for a tree can
    # refer to itself, since the reference is only resolved once there is a
    # value to decode.
    #
    # @see Decoding::Decoders.lazy
    class Lazy < Decoder
      # @yieldreturn [Decoding::Decoder<a>]
      def initialize(&block)
        @block = block
        super()
      end

      # @param value [Object]
      # @return [Decoding::Result<a>]
      def call(value) = decoder.call(value)

      private

      def decoder = @decoder ||= @block.call.to_decoder
    end
  end
end
