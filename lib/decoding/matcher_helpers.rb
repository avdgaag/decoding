# frozen_string_literal: true

module Decoding
  # Shared logic for the matchers that describe decoding, loaded along with
  # them by `require "decoding/rspec"`.
  #
  # Decoders report failures as {Decoding::Failure} values, but {Decoding.decode}
  # renders those into strings, so matchers have to understand both.
  module MatcherHelpers
    # Split the error value of a result into its message and the path it
    # occurred at, with the outermost path segment first.
    #
    # @param result [Decoding::Result]
    # @return [Array(String, Array)]
    def describe_failure(result)
      error = result.unwrap_err(nil)
      return [error.msg, error.path.reverse] if error.is_a?(Decoding::Failure)

      match = error.to_s.match(/\AError at \.(?<path>.+?): (?<msg>.*)\z/m)
      match ? [match[:msg], match[:path].split(".")] : [error.to_s, []]
    end

    # @param path [Array]
    # @return [String]
    def render_path(path) = path.empty? ? "" : " at .#{path.join(".")}"

    # The path set by the `at` chain, if any.
    #
    # @return [Array]
    def expected_path = @expected_path ||= []

    # @param path [Array]
    # @return [Boolean]
    def path_matches?(path) = path.map(&:to_s) == expected_path.map(&:to_s)

    # Compare a decoded value to what the example expects. Values are
    # compared strictly, so that a decoder returning a value of the wrong
    # type is not mistaken for a success, unless the example expects a
    # matcher rather than a value.
    #
    # @param expected [Object]
    # @param actual [Object]
    # @return [Boolean]
    def matches_value?(expected, actual)
      return values_match?(expected, actual) if RSpec::Support.is_a_matcher?(expected)

      actual.eql?(expected)
    end
  end
end
