# frozen_string_literal: true

require_relative "../matcher_helpers"

# Passes when the given {Decoding::Result} is an `Ok` holding the expected
# value. The expected value may itself be a matcher.
#
#     expect(Decoding.decode(decoder, "foo")).to succeed_with("foo")
RSpec::Matchers.define :succeed_with do |expected|
  include Decoding::MatcherHelpers

  match do |actual|
    actual.is_a?(Decoding::Result) && actual.ok? && matches_value?(expected, actual.unwrap!)
  end

  failure_message do |actual|
    next "expected a Decoding::Result, got #{description_of(actual)}" unless actual.is_a?(Decoding::Result)

    outcome =
      if actual.ok?
        "it succeeded with #{description_of(actual.unwrap!)}"
      else
        "it failed with #{description_of(actual.unwrap_err(nil).to_s)}"
      end
    "expected the result to succeed with #{description_of(expected)}, but #{outcome}"
  end

  failure_message_when_negated do
    "expected the result not to succeed with #{description_of(expected)}"
  end
end
