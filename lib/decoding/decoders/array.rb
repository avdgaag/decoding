# frozen_string_literal: true

require_relative "../result"
require_relative "../decoder"

module Decoding
  module Decoders
    # Decode an array where all values match a given decoder.
    class Array < Decoder
      def initialize(decoder)
        @decoder = decoder.to_decoder
        super()
      end

      def call(value)
        if value.is_a?(::Array)
          value
            .each_with_index
            .map { |v, i| @decoder.call(v).map_err { |e| "error decoding array item #{i}: #{e}" } }
            .then { all _1 }
        else
          err("expected an Array, got: #{value.class}")
        end
      end
    end
  end
end
