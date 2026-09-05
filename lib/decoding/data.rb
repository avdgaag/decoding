# frozen_string_literal: true

require_relative "decoders"

module Decoding
  # Wrapper around Ruby's `Data` class, providing a way to both define a new
  # data class as usual but including a decoder to decode a value into such a
  # data value.
  #
  # @example
  #   User = Decoding::Data.define(
  #     name: field("postName", string),
  #     age: field("yearsOld", integer)
  #   ) do
  #    def greet
  #      "Hello, my name is #{name} and I am #{age} years old."
  #    end
  #  end
  #  payload = { "postName" => "John", "yearsOld" => 30 }
  #  Decoding.decode(User.decoder, payload) => Decoding::Ok(user)
  #  user.greet # => "Hello, my name is John and I am 30 years old."
  # @return [Class]
  module Data
    # @param attributes [Hash<Symbol, Decoding::Decoder>] A hash of attribute
    #   names and decoders
    # @see ::Data.define
    # @return [Class] A new data class with a `decoder` method.
    def self.define(attributes, &)
      # First ensure we have a hash of attribute names and decoders
      attributes = attributes.to_h do |key, value|
        [key.to_sym, value.to_decoder]
      end

      # Define the data class as usual
      data_class = ::Data.define(*attributes.keys, &)

      # Add a special `decode` method to use the provided decoders to decode a
      # value as hash and build a new instance with it
      data_class.define_singleton_method(:decoder) do
        Decoding::Decoders.map(
          Decoding::Decoders.decode_hash(attributes)
        ) { |attrs| new(**attrs) }
      end

      # Adapt to `to_decoder` protocol
      data_class.define_singleton_method(:to_decoder) { decoder }

      # Return the data class so regular assignment like
      # `User = ::Data.define(...)` works.
      data_class
    end
  end
end
