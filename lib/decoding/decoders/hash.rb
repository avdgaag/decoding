# frozen_string_literal: true

require_relative "../decoder"

module Decoding
  module Decoders
    # Decode an arbitrary hash using decoders for keys and values.
    class Hash < Decoder
      # @param key_decoder [Decoding::Decoder]
      # @param value_decoder [Decoding::Decoder]
      def initialize(key_decoder, value_decoder)
        @key_decoder = key_decoder.to_decoder
        @value_decoder = value_decoder.to_decoder
        super()
      end

      def call(value)
        if value.is_a?(::Hash)
          key_value_pairs = value.map do |k, v|
            all(
              [
                @key_decoder
                  .call(k)
                  .map_err { |e| "error decoding key #{k.inspect}: #{e}" },

                @value_decoder
                  .call(v)
                  .map_err { |e| "error decoding value for key #{k.inspect}: #{e}" }
              ]
            )
          end
          all(key_value_pairs).map(&:to_h)
        else
          err("expected Hash, got #{value.class}")
        end
      end
    end
  end
end
