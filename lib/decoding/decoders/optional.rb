# frozen_string_literal: true

require_relative "../decoder"

module Decoding
  module Decoders
    # A decoder for a value that may or may not be `nil`, decoding any other
    # value with a given decoder.
    #
    # The given decoder gets to decode a `nil` value first, so it can give it a
    # meaning of its own. Only when it fails to do so does this decoder treat
    # `nil` as an absent value.
    #
    # @see Decoding::Decoders.optional
    class Optional < Decoder
      # @param decoder [Decoding::Decoder<a>]
      def initialize(decoder)
        @decoder = decoder.to_decoder
        super()
      end

      # @param value [Object]
      # @return [Decoding::Result<a, nil>]
      def call(value)
        result = @decoder.call(value)
        return result if result.ok?
        return ok(nil) if value.nil?

        result
      end
    end
  end
end
