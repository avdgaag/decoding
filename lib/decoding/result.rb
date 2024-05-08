# frozen_string_literal: true

module Decoding
  class Result
    def self.ok(value) = Ok.new(value)
    def self.err(value) = Err.new(value)

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

    def ok? = false
    def err? = false
    def unwrap(default_value) = default_value
    def map = self
    def map_err = self
    def then = self
  end

  class Ok < Result
    public_class_method :new

    def ok? = true
    def unwrap(_) = value
    def map = self.class.new(yield value)
  end

  class Err < Result
    public_class_method :new

    def err? = true
    def map_err = self.class.new(yield value)
  end
end
