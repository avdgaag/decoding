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
      # @private
      Err = Result.err("None of the decoders matched")

      # @param decoder [Decoding::Decoder<Object>]
      # @param decoders [Decoding::Decoder<Object>]
      def initialize(decoder, *decoders)
        @decoders = [decoder, *decoders].map(&:to_decoder)
        super()
      end

      # @param value [Object]
      # @return [Decoding::Result<Object>]
      def call(value)
        @decoders.lazy.map { _1.call(value) }.find(-> { Err }, &:ok?)
      end
    end
  end
end
