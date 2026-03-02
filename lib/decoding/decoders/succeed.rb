# frozen_string_literal: true

require_relative "../decoder"

module Decoding
  module Decoders
    # A decoder that always succeeds with a predetermined value, ignoring any
    # input. This is useful for providing default values or as a building block
    # in decoder composition.
    #
    # @example Always return a fixed value
    #   decode(Succeed.new(5), "anything") # => Decoding::Ok(5)
    #
    # @example Use with field to provide defaults
    #   decode(any(field("x", integer), Succeed.new(0)), {})
    #   # => Decoding::Ok(0)
    class Succeed < Decoder
      # @param value [Object] the value to always return
      def initialize(value)
        @value = value
        super()
      end

      # @param _value [Object] ignored input
      # @return [Decoding::Result<Object>]
      def call(_value) = ok(@value)
    end
  end
end
