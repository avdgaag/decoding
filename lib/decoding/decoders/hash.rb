# frozen_string_literal: true

require_relative "../decoder"

module Decoding
  module Decoders
    # Decode an arbitrary hash using decoders for keys and values.
    #
    # @see Decoding::Decoders.hash
    class Hash < Decoder
      # @param key_decoder [Decoding::Decoder<a>]
      # @param value_decoder [Decoding::Decoder<b>]
      def initialize(key_decoder, value_decoder)
        @key_decoder = key_decoder.to_decoder
        @value_decoder = value_decoder.to_decoder
        super()
      end

      # @param value [Object]
      # @return [Decoding::Result<Hash<a, b>>]
      def call(value)
        return err(failure("expected Hash, got #{value.class}")) unless value.is_a?(::Hash)

        key_value_pairs = value.map do |k, v|
          all(
            [
              @key_decoder
                .call(k)
                .map_err { |e| failure("error decoding key #{k.inspect}: #{e}") },

              @value_decoder
                .call(v)
                .map_err { |e| failure("error decoding value for key #{k.inspect}: #{e}") }
            ]
          )
        end
        all(key_value_pairs).map(&:to_h)
      end
    end
  end
end
