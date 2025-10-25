# frozen_string_literal: true

module Decoding
  class Failure
    protected attr_reader :msg
    protected attr_reader :path

    # @paramn msg [String]
    def initialize(msg)
      @msg = msg
      @path = []
    end

    def eql?(other)
      other.is_a?(self.class) &&
        msg == other.msg &&
        path == other.path
    end
    alias == eql?

    # Add segments to the stack of errors.
    #
    # This is useful to create clearer error messages when using compound
    # decoders, such as `array(string)`. If the `string` decoder fails with an
    # error, the `array` decoder can push `3` to the stack to indicate that
    # happened at index 3 in its input value.
    #
    # @param segment [String]
    # @return [Decoding::Failure]
    def push(segment)
      @path << segment
      self
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
