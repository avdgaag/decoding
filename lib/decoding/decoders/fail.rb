# frozen_string_literal: true

require_relative "../decoder"

module Decoding
  module Decoders
    # A decoder that always fails with a predetermined error message, ignoring
    # any input. This is useful for signaling errors in conditional decoder
    # composition, such as inside {Decoders::AndThen}.
    #
    # @example Always fail with a message
    #   decode(Fail.new("unsupported"), "anything")
    #   # => Decoding::Err("unsupported")
    #
    # @example Use in conditional decoding
    #   and_then(field("version", integer)) do |version|
    #     case version
    #     when 1 then field("name", string)
    #     else Fail.new("unsupported version: #{version}")
    #     end
    #   end
    class Fail < Decoder
      # @param message [String] the error message to always return
      def initialize(message)
        @message = message
        super()
      end

      # @param _value [Object] ignored input
      # @return [Decoding::Result<Object>]
      def call(_value) = err(failure(@message))
    end
  end
end
