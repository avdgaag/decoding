# frozen_string_literal: true

require_relative "decoders/match"
require_relative "decoders/map"
require_relative "decoders/any"
require_relative "decoders/field"
require_relative "decoders/array"
require_relative "decoders/index"
require_relative "decoders/hash"
require_relative "decoders/and_then"
require_relative "result"

module Decoding
  # Decoders are composable functions for deconstructing unknown input values
  # into known output values.
  module Decoders
    module_function

    # Run a given `decoder` on the given input `value`.
    #
    # @param decoder [Decoding::Decoder<a>]
    # @param value [Object]
    # @return [Decoding::Result<a>]
    def decode(decoder, value) = decoder.call(value)

    # Decode any string value.
    #
    # @example
    #   decode(string, "foo") # => Decoding::Ok("foo")
    # @return [Decoding::Decoder<String>]
    def string = Decoders::Match.new(String)

    # Decode any integer value.
    #
    # @example
    #   decode(integer, 1) # => Decoding::Ok(1)
    # @return [Decoding::Decoder<Integer>]
    def integer = Decoders::Match.new(Integer)

    # Decode any float value.
    #
    # @example
    #   decode(float, 0.5) # => Decoding::Ok(0.5)
    # @return [Decoding::Decoder<Float>]
    def float = Decoders::Match.new(Float)

    # Decode any numeric value (includes both integers and floats).
    #
    # @example
    #   decode(numeric, 1) # => Decoding::Ok(1)
    #   decode(numeric, 1.5) # => Decoding::Ok(1.5)
    # @return [Decoding::Decoder<Numeric>]
    def numeric = Decoders::Match.new(Numeric)

    # Decode a `nil` value.
    #
    # @example
    #   decode(Decoders.nil, nil) # => Decoding::Ok(nil)
    # @return [Decoding::Decoder<NilClass>]
    def nil = Decoders::Match.new(NilClass)

    # Decode a `true` value.
    #
    # @example
    #   decode(Decoding.true, true) # => Decoding::Ok(true)
    # @return [Decoding::Decoder<TrueClass>]
    def true = Decoders::Match.new(TrueClass)

    # Decode a `false` value.
    #
    # @example
    #   decode(Decoders.false, false) # => Decoding::Ok(false)
    # @return [Decoding::Decoder<FalseClass>]
    def false = Decoders::Match.new(FalseClass)

    # A decoder that always succeeds with the given value.
    #
    # @example
    #   decode(succeed(5), "foo") # => Decoding::Ok(5)
    # @return [Decoding::Decoder<String>]
    def succeed(value) = ->(_) { Result.ok(value) }

    # A decoder that always fails with the given value.
    #
    # @example
    #   decode(fail("oh no"), "foo") # => Decoding::Err("oh no")
    # @return [Decoding::Decoder<String>]
    def fail(value) = ->(_) { Result.err(value) }

    # Decode a value with the given decoder and, if successful, apply a block to
    # the decoded result.
    #
    # Given multiple decoders, apply them all to the same value and, if all
    # succeeded, create a single output value from them.
    #
    # @example map over a single value
    #   decode(map(string, &:upcase), "foo") # => Decoding::Ok("FOO")
    # @example map over multiple values
    #   decode(
    #     map(
    #       field("id", integer),
    #       field("name", string)
    #     ) { |id, name| [id, name] },
    #     { "id" => 1, "name" => "john" }
    #   )
    #   # => [1, "john"]
    # @param decoder [Decoding::Decoder<a>]
    # @yieldparam value [a]
    # @yieldreturn value [b]
    # @return [Decoding::Decoder<b>]
    def map(...) = Decoders::Map.new(...)

    # Decode a value by trying many different decoders in order, using the first
    # matching result -- or a failure when none of the given decoders succeed.
    #
    # @example
    #   decode(any(string, integer), 12) # => Decoding::Ok(12)
    #   decode(any(string, integer), '12') # => Decoding::Ok('12')
    # @param decoder [Decoding::Decoder<a>]
    # @return [Decoding::Decoder<a>]
    def any(...) = Decoders::Any.new(...)

    # Decode a boolean value (either `true` or `false`).
    #
    # @example
    #   decode(boolean, true) # => Decoding::Ok(true)
    #   decode(boolean, false) # => Decoding::Ok(false)
    # @return [Decoding::Decoder<Boolean>]
    def boolean = any(self.true, self.false)

    # Decode a value that may or may not be `nil`.
    #
    # @example
    #   decode(string, "foo") # => Decoding::Ok("foo")
    #   decode(string, nil) # => Decoding::Ok(nil)
    # @param decoder [Decoding::Decoder<a>]
    # @return [Decoding::Decoder<a, nil>]
    def optional(decoder) = any(decoder, self.nil)

    # Decode a value from a given key in a hash.
    #
    # @example
    #   decode(field('id', integer), { 'id' => 5 }) # => Decoding::Ok(5)
    # @param key [Object]
    # @param decoder [Decoding::Decoder<a>]
    # @return [Decoding::Decoder<a>]
    def field(...) = Decoders::Field.new(...)

    # Decode an array of values using a given decoder.
    #
    # @example
    #   decode(array(integer), [1, 2, 3]) # => Decoding::Ok([1, 2, 3])
    # @param decoder [Decoding::Decoder<a>]
    # @return [Decoding::Decoder<Array<a>>]
    def array(...) = Decoders::Array.new(...)

    # Decode an array element by index using a given decoder.
    #
    # @example
    #   decode(index(0, integer), [1, 2, 3]) # => Decoding::Ok(1)
    # @param index [Integer]
    # @param decoder [Decoding::Decoder<a>]
    # @return [Decoding::Decoder<a>]
    def index(...) = Decoders::Index.new(...)

    # Decode a Hash with arbitrary contents using two decoders for the keys and
    # the pairs.
    #
    # @example
    #   decode(hash(string, integer), { 'john' => 1 })
    #   # => Decoding::Ok({ 'john' => 1 })
    # @param key_decoder [Decoding::Decoder<a>]
    # @param value_decoder [Decoding::Decoder<b>]
    # @return [Decoding::Decoder<Hash<a, b>>]
    def hash(...) = Decoders::Hash.new(...)

    # Decode a String value into a symbol.
    #
    # @example
    #   decode(symbol, "foo") # => Decoding::Ok(:foo)
    # @return [Decoding::Decoder<Symbol>]
    def symbol = map(string, &:to_sym)

    # Create a decoder that depends on a previously decoded value.
    #
    # @example
    #   decoder = and_then(field("version", integer)) do |version|
    #     if version == 1
    #       field("name", string)
    #     else
    #       field("fullName", string)
    #     end
    #   end
    #   decode(decoder, { "version" => 1, "name" => "john" })
    #   # => Decoding::Ok("john")
    #   decode(decoder, { "version" => 2, "fullName" => "john" })
    #   # => Decoding::Ok("john")
    # @param decoder [Decoding::Decoder<a>]
    # @yieldparam value [a]
    # @yieldreturn [Decoding::Decoder<b>]
    # @return [Decoding::Decoder<b>]
    def and_then(...) = Decoding::AndThen.new(...)
  end
end
