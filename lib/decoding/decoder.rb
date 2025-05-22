# frozen_string_literal: true

require "forwardable"
require_relative "result"
require_relative "failure"

module Decoding
  # A decoder is a callable object that reads any input value and returns an
  # optionally transformed value.
  #
  # @abstract
  class Decoder
    extend Forwardable
    def_delegators "Decoding::Result", :all, :ok, :err

    # @param value [Object]
    # @return [Decoding::Result<Object>]
    def call(value); end

    # @return [Decoding::Decoder<a>]
    def to_decoder = self

    # @param str [String]
    # @return [Decoding::Failure]
    def failure(str) = Decoding::Failure.new(str)
  end
end
