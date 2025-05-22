# frozen_string_literal: true

require_relative "../result"
require_relative "../decoder"

module Decoding
  module Decoders
    # Decode an array where all values match a given decoder.
    #
    # @see Decoding::Decoders.array
    class Array < Decoder
      # @param decoder [Decoding::Decoder<a>]
      def initialize(decoder)
        @decoder = decoder.to_decoder
        super()
      end

      # @param value [Object]
      # @return [Decoding::Result<a>]
      def call(value)
        if value.is_a?(::Array)
          value
            .each_with_index
            .map { |v, i| @decoder.call(v).map_err { _1.push(i) } }
            .then { all _1 }
        else
          err("expected an Array, got: #{value.class}")
        end
      end
    end
  end
end
