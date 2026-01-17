# frozen_string_literal: true

module Decoding
  # A failure is an error message, much like a string, but with an added stack
  # of earlier messages.
  #
  # This is useful to create clearer error messages when using compound
  # decoders, such as `array(string)`. If the `string` decoder fails with an
  # error, the `array` decoder can push `3` to the stack to indicate that
  # happened at index 3 in its input value.
  class Failure
    # @param msg [String]
    # @param path [Array] Internal parameter for creating copies with updated paths
    def initialize(msg, path = [])
      @msg = msg
      @path = path.dup.freeze
      freeze
    end

    def eql?(other)
      other.is_a?(self.class) &&
        msg == other.msg &&
        path == other.path
    end
    alias == eql?

    # Add segments to the stack of errors.
    # Returns a new Failure instance with the updated path.
    #
    # @param segment [String]
    # @return [Decoding::Failure]
    def push(segment)
      self.class.new(@msg, @path + [segment])
    end

    def to_s
      if @path.any?
        "Error at .#{@path.reverse.join(".")}: #{@msg}"
      else
        @msg
      end
    end

    protected

    attr_reader :msg, :path
  end
end
