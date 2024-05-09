# frozen_string_literal: true

module Decoding
  # A decoder is a callable object that reads any input value and returns an
  # optionally transformed value.
  #
  # Note: this is an abstract class; use any of its subclasses instead of this
  # class directly.
  class Decoder
    # @param value [Object]
    # @return [Decoding::Result<Object>]
    def call(value); end
  end
end
