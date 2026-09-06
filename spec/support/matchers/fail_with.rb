# frozen_string_literal: true

require_relative "helpers"

# Passes when the given {Decoding::Result} is an `Err` that failed with the
# expected message. Chain `at` to also assert where the failure occurred,
# naming the path segments outermost first. The expected message may itself be
# a matcher.
#
#     expect(Decoding.decode(decoder, [1])).to fail_with("expected String, got Integer").at(0)
#
# Failures are recognised both as {Decoding::Failure} values and as the strings
# they turn into once {Decoding.decode} has rendered them.
RSpec::Matchers.define :fail_with do |expected|
  include Decoding::SpecSupport::MatcherHelpers

  match do |actual|
    next false unless actual.is_a?(Decoding::Result) && actual.err?

    msg, path = describe_failure(actual)
    matches_value?(expected, msg) && path_matches?(path)
  end

  chain :at do |*segments|
    @expected_path = segments
  end

  failure_message do |actual|
    next "expected a Decoding::Result, got #{description_of(actual)}" unless actual.is_a?(Decoding::Result)

    outcome =
      if actual.ok?
        "it succeeded with #{description_of(actual.unwrap!)}"
      else
        msg, path = describe_failure(actual)
        "it failed with #{description_of(msg)}#{render_path(path)}"
      end
    "expected the result to #{description}, but #{outcome}"
  end

  failure_message_when_negated do
    "expected the result not to #{description}"
  end

  description do
    "fail with #{description_of(expected)}#{render_path(expected_path)}"
  end

  def expected_path = @expected_path ||= []

  def render_path(path) = path.empty? ? "" : " at .#{path.join(".")}"

  # Split an error value into its message and the path it occurred at, with the
  # outermost segment first.
  def describe_failure(result)
    error = result.unwrap_err(nil)
    return [error.msg, error.path.reverse] if error.is_a?(Decoding::Failure)

    match = error.to_s.match(/\AError at \.(?<path>.+?): (?<msg>.*)\z/m)
    match ? [match[:msg], match[:path].split(".")] : [error.to_s, []]
  end
end
