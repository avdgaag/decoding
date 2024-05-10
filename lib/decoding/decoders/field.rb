# frozen_string_literal: true

require_relative "../decoder"

module Decoding
  module Decoders
    # Decode a value from key in a given hash.
    class Field < Decoder
      # @param key [Object]
      # @param decoder [Decoding::Decoder<a>]
      def initialize(key, decoder)
        @key = key
        @decoder = decoder
        super()
      end

      def call(value)
        if value.is_a?(::Hash)
          if value.key?(@key)
            @decoder.call(value.fetch(@key))
          else
            err("expected a Hash with key #{@key}")
          end
        else
          err("expected a Hash, got: #{value.inspect}")
        end
      end
    end
  end
end
