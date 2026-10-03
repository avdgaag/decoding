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

        all(value) { |k, v| decode_entry(k, v) }.map(&:to_h)
      end

      private

      # Decode a single key and value into a pair, leaving the value alone
      # when the key cannot be decoded.
      def decode_entry(key, value)
        @key_decoder
          .call(key)
          .map_err { _1.map { |msg| "invalid key: #{msg}" }.push(key) }
          .and_then do |decoded_key|
            @value_decoder.call(value).map_err { _1.push(key) }.map { [decoded_key, _1] }
          end
      end
    end
  end
end
