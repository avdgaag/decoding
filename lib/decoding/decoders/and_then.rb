# frozen_string_literal: true

require_relative "../decoder"

module Decoding
  # Create a decoder that depends on a previously decoded value.
  class AndThen < Decoder
    # @param decoder [Decoding::Decoder<a>]
    # @yieldparam [a]
    # @yieldreturn [Decoding::Decoder<b>]
    # @return [Decoding::Decoder<b>]
    def initialize(decoder, &block)
      @decoder = decoder
      @block = block
      super()
    end

    def call(value)
      @decoder.call(value).and_then do |decoded_value|
        @block.call(decoded_value).call(value)
      end
    end
  end
end
