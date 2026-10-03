# frozen_string_literal: true

require_relative "error"

module Decoding
  # Raised when calling {Result#unwrap!} on an `Err` value.
  class UnwrapError < Error; end

  # A result represent the outcome of some computation that can succeed or fail.
  # The results are represented with two subclasses of `Result`: `Ok` and `Err`.
  # Each hold a single result value.
  #
  # The use of a result is the common interface provided to callers for
  # transforming or chaining result values.
  #
  # @abstract
  class Result
    # Construct a new `Ok` value with the given `value`.
    #
    # @param value [a]
    # @return [Decoding::Ok<a>]
    def self.ok(value) = Ok.new(value)

    # Construct a new `Err` value with the given `value`.
    #
    # @param value [a]
    # @return [Decoding::Err<a>]
    def self.err(value) = Err.new(value)

    # Collapse array of result values into a single result, or return the
    # first `Err` value.
    #
    # Given a block, each item is mapped to a result with the block first,
    # one at a time, and items after the first `Err` are not mapped at all.
    #
    # @example
    #   all(Ok(1), Ok(2)) # => Ok([1, 2])
    #   all(Ok(1), Err("error")) # => Err("error")
    #   all([1, 2]) { Ok(_1 * 10) } # => Ok([10, 20])
    # @overload all(results)
    #   @param results [Enumerable<Result<a>>]
    # @overload all(items)
    #   @param items [Enumerable<Object>]
    #   @yieldparam item [Object]
    #   @yieldreturn [Result<a>]
    # @return [Result<Array<a>>]
    def self.all(items)
      values = []
      items.each_entry do |item|
        result = (block_given? ? yield(item) : item).to_result
        return result if result.err?

        values << result.unwrap(nil)
      end
      ok(values)
    end

    private_class_method :new

    # @return [Object]
    attr_reader :value

    protected :value

    # Computed when asked for rather than up front: results are rarely used as
    # hash keys, and hashing a large decoded value for every result created
    # made decoding a collection quadratic.
    #
    # @private
    def hash = [self.class, value].hash

    def initialize(value)
      @value = value
      freeze
    end

    def deconstruct
      [value]
    end

    def eql?(other)
      other.is_a?(self.class) && value == other.value
    end
    alias == eql?

    def inspect
      "#<#{self.class} #{value.inspect}>"
    end

    # Whether this value is an `Ok` value.
    #
    # @return [Boolean]
    def ok? = false

    # Whether this value is an `Err` value.
    #
    # @return [Boolean]
    def err? = false

    # Extract the value out of a `Result` value. In case of an `Ok`, this
    # returns the result's value. In case of an `Err`, the given `default_value`
    # is returned.
    #
    # @param default_value [Object]
    # @return [Object]
    def unwrap(default_value) = default_value

    # Extract the value out of a `Result` value. In case of an `Ok`, this
    # returns the result's value. In case of an `Err`, a {UnwrapError} is
    # raised with the error value as its message.
    #
    # @raise [Decoding::UnwrapError] if the result is an `Err` value.
    # @return [Object]
    def unwrap! = raise(UnwrapError, value.to_s)

    # Extract the error value out of a `Result` value. In case of an `Err`, this
    # returns the result's value. In case of an `Ok`, the given `default_value`
    # is returned.
    #
    # @param default_value [Object]
    # @return [Object]
    def unwrap_err(default_value) = default_value

    # Create a new `Result` value for the result of the block applied to this
    # result's `value`. `Err` values are returned as-is.
    #
    # @example
    #   Result.ok(123).map { |i| i * 2 } # => Ok(246)
    #   Result.err("error").map { |i| i * 2 } # => Err("error")
    # @yieldparam value [a]
    # @yieldreturn [b]
    # @return [Decoding::Result<b>]
    def map = self

    # Create a new `Result` value for the result of the block applied to this
    # result's `value`. `Ok` values are returned as-is.
    #
    # @example
    #   Result.ok(123).map { |s| s.upcase } # => Ok(123)
    #   Result.err("error").map { |s| s.upcase } # => Err("ERROR")
    # @yieldparam value [a]
    # @yieldreturn [b]
    # @return [Decoding::Result<b>]
    def map_err = self

    # Combine two `Result` values if they are both `Ok` using the given block, or
    # return the first `Err` value.
    #
    # @overload and(other)
    #   @param other [Decoding::Result<a>]
    #   @yieldparam left [Object]
    #   @yieldparam right [Object]
    #   @yieldreturn [c]
    #   @return [Decoding::Result<c>]
    def and(_) = self

    # Transform a result using a block that will also return a result.
    #
    # @yieldparam value [Object]
    # @yieldreturn [Decoding::Result<a>]
    # @return [Decoding::Result<a>]
    def and_then = self

    def to_result = self
  end

  # The `Ok` value represents the result of a successful computation.
  #
  # @see Decoding::Err
  class Ok < Result
    public_class_method :new

    def ok? = true
    def unwrap(_) = value
    def unwrap! = value
    def map = self.class.new(yield value)

    def and(other)
      return other unless other.is_a?(self.class)

      self.class.new(yield value, other.value)
    end

    def and_then = yield(value).to_result
  end

  # The `Err` value represents the result of an unsuccessful computation.
  #
  # @see Decoding::Err
  class Err < Result
    public_class_method :new

    def err? = true
    def map_err = self.class.new(yield value)
    def unwrap_err(_) = value
  end
end
