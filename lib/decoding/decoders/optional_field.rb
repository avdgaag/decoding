# frozen_string_literal: true

require_relative "../decoder"
require_relative "field"

module Decoding
  module Decoders
    # Decode a value from a key that may be absent from a hash.
    #
    # This differs from wrapping a {Field} decoder in an {Optional} decoder,
    # which describes a key that is present but may hold `nil`. Here the key
    # itself may be missing; when it is present, its value must still decode.
    #
    # @see Decoding::Decoders.optional_field
    class OptionalField < Decoder
      # @param key [Object]
      # @param decoder [Decoding::Decoder<a>]
      # @param default [Object] used when the key is absent.
      def initialize(key, decoder, default: nil)
        @key = String(key)
        @field = Field.new(@key, decoder)
        @default = default
        super()
      end

      # @param value [Object]
      # @return [Decoding::Result<a>]
      def call(value)
        return ok(@default) if value.is_a?(::Hash) && !value.key?(@key)

        @field.call(value)
      end
    end
  end
end
