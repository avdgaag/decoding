# frozen_string_literal: true

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

      # @param value [Object]
      # @return [Decoding::Result<a>]
      def call(value)
        if @pattern === value
          ok(value)
        elsif @pattern.is_a?(Class)
          err(failure("expected #{@pattern}, got #{value.class}"))
        else
          err(failure("expected value matching #{@pattern.inspect}, got: #{value.inspect}"))
        end
      end
    end
  end
end
