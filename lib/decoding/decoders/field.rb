# frozen_string_literal: true

require_relative "../decoder"

module Decoding
  module Decoders
    # Decode a value from key in a given hash.
    #
    # @see Decoding::Decoders.field
    class Field < Decoder
      # @param key [Object]
      # @param decoder [Decoding::Decoder<a>]
      def initialize(key, decoder)
        @key = key.to_str
        @decoder = decoder.to_decoder
        super()
      end

      # @param value [Object]
      # @return [Deceoding::Result<a>]
      def call(value)
        if value.is_a?(::Hash)
          if value.key?(@key)
            @decoder.call(value.fetch(@key)).map_err { _1.push(@key) }
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
