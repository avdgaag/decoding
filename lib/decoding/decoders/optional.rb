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
    # Most decoders cannot decode `nil`, and building the failure that says so
    # costs more than decoding most values. Since a decoder gives the same
    # result for the same input, this decoder remembers when the given decoder
    # has failed to decode `nil`, and stops asking it about `nil` from then on.
    #
    # @see Decoding::Decoders.optional
    class Optional < Decoder
      # @param decoder [Decoding::Decoder<a>]
      def initialize(decoder)
        @decoder = decoder.to_decoder
        @fails_on_nil = false
        super()
      end

      # @param value [Object]
      # @return [Decoding::Result<a, nil>]
      def call(value)
        return ok(nil) if value.nil? && @fails_on_nil

        result = @decoder.call(value)
        return result if result.ok? || !value.nil?

        @fails_on_nil = true
        ok(nil)
      end
    end
  end
end
