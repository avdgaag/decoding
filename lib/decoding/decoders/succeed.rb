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
    # @example Use in conditional decoding
    #   and_then(field("kind", string)) do |kind|
    #     kind == "none" ? Succeed.new(nil) : field("value", integer)
    #   end
    #
    # Note this is not the way to give a key a default value: combining it with
    # {Any} would also swallow the failure of a key that is present but holds a
    # value of the wrong type. Use {OptionalField} for that instead.
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
