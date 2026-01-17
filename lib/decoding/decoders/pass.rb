# frozen_string_literal: true

module Decoding
  module Decoders
    # Decoder that returns the original value as-is. You are not likely to need
    # this that often, as it kind of defeats the point of decoding -- but it
    # might be useful to inspect the original input value for logging or
    # debugging purposes.
    class Pass < Decoder
      def call(value) = ok(value)
    end
  end
end
