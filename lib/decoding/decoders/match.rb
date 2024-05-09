# frozen_string_literal: true

require_relative "../result"
require_relative "../decoder"

module Decoding
  module Decoders
    # Decoder that matches values using the `===` operator. This will work with
    # regular expressions or classes.
    class Match < Decoder
      # @param pattern [#===]
      def initialize(pattern)
        @pattern = pattern
        super()
      end

      def call(value)
        if @pattern === value
          Result.ok(value)
        elsif @pattern.is_a?(Class)
          Result.err("expected #{@pattern}, got #{value.class}")
        else
          Result.err("expected value matching #{@pattern.inspect}, got: #{value.inspect}")
        end
      end
    end
  end
end
