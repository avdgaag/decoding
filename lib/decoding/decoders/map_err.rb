# frozen_string_literal: true

require_relative "../decoder"

module Decoding
  module Decoders
    # A decoder that replaces the error message of a decoder that failed,
    # leaving successful results untouched.
    #
    # @see Decoding::Decoders.map_err
    class MapErr < Decoder
      # @param decoder [Decoding::Decoder<a>]
      # @yieldparam msg [String]
      # @yieldparam value [Object]
      # @yieldreturn [String]
      def initialize(decoder, &block)
        @decoder = decoder.to_decoder
        @block = block
        super()
      end

      # @param value [Object]
      # @return [Decoding::Result<a>]
      def call(value)
        @decoder.call(value).map_err { |f| f.map { @block.call(_1, value) } }
      rescue StandardError => e
        err(failure("error in map_err block: #{e.message}"))
      end
    end
  end
end
