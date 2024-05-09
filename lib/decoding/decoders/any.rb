# frozen_string_literal: true

require_relative "../result"
require_relative "../decoder"

module Decoding
  module Decoders
    # A decoder wrapping any number of decoders, finding the first one that
    # matches the given value and returning its result.
    class Any < Decoder
      Err = Result.err("None of the decoders matched")

      # @param decoders [Decoding::Decoder<a>]
      def initialize(decoder, *decoders)
        @decoders = [decoder, *decoders]
        super()
      end

      def call(value)
        @decoders.lazy.map { _1.call(value) }.find(-> { Err }, &:ok?)
      end
    end
  end
end
