# frozen_string_literal: true

require_relative "../result"
require_relative "../decoder"

module Decoding
  module Decoders
    # Decode an array where all values match a given decoder.
    class Index < Decoder
      Err = Result.err("error decoding array: index is out of bounds")

      def initialize(index, decoder)
        @index = index.to_int
        @decoder = decoder.to_decoder
        super()
      end

      def call(value)
        return err("expected an Array, got: #{value.class}") unless value.is_a?(::Array)

        @decoder
          .call(value.fetch(@index))
          .map_err { "error decoding array item #{@index}: #{_1}" }
      rescue IndexError => e
        err("error decoding array: #{e}")
      end
    end
  end
end
