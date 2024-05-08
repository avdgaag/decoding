# frozen_string_literal: true

require_relative "../result"

module Decoding
  module Decoders
    # Decoder that matches values using the `===` operator. This will work with
    # regular expressions or classes.
    class Match
      # @param pattern [#===]
      def initialize(pattern)
        @pattern = pattern
      end

      # @param value [Object]
      def call(value)
        if @pattern === value
          Result.ok(value)
        else
          Result.err("expected value matching #{@pattern.inspect}, got: #{value.inspect}")
        end
      end
    end
  end
end
