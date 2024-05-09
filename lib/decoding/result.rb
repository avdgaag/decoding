# frozen_string_literal: true

module Decoding
  # A result represent the outcome of some computation that can succeed or fail.
  # The results are represented with two subclasses of `Result`: `Ok` and `Err`.
  # Each hold a single result value.
  #
  # The use of a result is the common interface provided to callers for
  # transforming or chaining result values.
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
    # @param results [Array<Result<a>>]
    # @return [Result<a>]
    def self.all(results)
      results.reduce(ok([])) do |acc, el|
        acc.and(el) { [*_1, _2] }
      end
    end

    private_class_method :new

    attr_reader :value, :hash

    protected :value

    def initialize(value)
      @value = value
      @hash = [self.class, value].hash
      freeze
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

    # Create a new `Result` value for the result of the block applied to this
    # result's `value`. `Err` values are returned as-is.
    #
    # @yieldparam value [a]
    # @yieldreturn [b]
    # @return [Decoding::Result<b>]
    def map = self

    # Create a new `Result` value for the result of the block applied to this
    # result's `value`. `Ok` values are returned as-is.
    #
    # @yieldparam value [a]
    # @yieldreturn [b]
    # @return [Decoding::Result<b>]
    def map_err = self

    # Combine two `Result` values if they are both `Ok` using the given block, or
    # return the first `Err` value.
    #
    # @param other [Decoding::Result<a>]
    # @yieldparam left [Object]
    # @yieldparam right [Object]
    # @yieldreturn [c]
    # @return [Decoding::Result<c>]
    def and(_) = self
  end

  # The `Ok` value represents the result of a successful computation.
  class Ok < Result
    public_class_method :new

    def ok? = true
    def unwrap(_) = value
    def map = self.class.new(yield value)

    def and(other)
      return other unless other.is_a?(self.class)

      self.class.new(yield value, other.value)
    end
  end

  # The `Err` value represents the result of an unsuccessful computation.
  class Err < Result
    public_class_method :new

    def err? = true
    def map_err = self.class.new(yield value)
  end
end
