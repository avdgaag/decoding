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
    # The error message, without the location it occurred at.
    #
    # @return [String]
    attr_reader :msg

    # The stack of segments describing where the error occurred, innermost
    # first.
    #
    # @return [Array]
    attr_reader :path

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

    # Create a copy of this failure with a transformed error message, retaining
    # the current stack of errors.
    #
    # This is useful for decoders that want to replace the error message of a
    # nested decoder with something more fitting, without losing the location
    # of the error.
    #
    # @yieldparam msg [String]
    # @yieldreturn [String]
    # @return [Decoding::Failure]
    def map = self.class.new(yield(@msg), @path)

    # Combine this failure with others into a single failure, using the given
    # block to build a single message from all of their messages.
    #
    # When all failures occurred at the same location, that location is kept for
    # the combined failure and left out of the individual messages, since the
    # combined failure already describes it. Otherwise each message describes
    # its own location.
    #
    # @param others [Array<Decoding::Failure>]
    # @yieldparam messages [Array<String>]
    # @yieldreturn [String]
    # @return [Decoding::Failure]
    def combine(others)
      failures = [self, *others]
      return self.class.new(yield(failures.map(&:to_s))) unless failures.map(&:path).uniq.size == 1

      self.class.new(yield(failures.map(&:msg)), @path)
    end

    def to_s
      if @path.any?
        "Error at .#{@path.reverse.join(".")}: #{@msg}"
      else
        @msg
      end
    end
  end
end
