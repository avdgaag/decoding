# frozen_string_literal: true

require_relative "matcher_helpers"

# Passes when the given decoder decodes the given input. Chain `to` to also
# assert the decoded value, or `failing_with` (optionally with `at`) to assert
# that decoding fails with a particular message. Both expected values may
# themselves be matchers.
#
#     expect(decoder).to decode_value(["foo"]).to(["foo"])
#     expect(decoder).to decode_value([1]).failing_with("expected String, got Integer").at(0)
#     expect(decoder).not_to decode_value(true)
RSpec::Matchers.define :decode_value do |input|
  include Decoding::SpecSupport::MatcherHelpers

  match do |actual|
    next false unless actual.respond_to?(:call)

    result = Decoding.decode(actual, input)
    next matches_failure?(result) if message_expected?
    next result.ok? && matches_value?(@expected_value, result.unwrap!) if value_expected?

    result.ok?
  end

  match_when_negated do |actual|
    raise ArgumentError, "use `not_to decode_value(input)` without `to` or `failing_with`" if message_expected? || value_expected?

    actual.respond_to?(:call) && Decoding.decode(actual, input).err?
  end

  chain :to do |value|
    @expected_value = value
    @value_expected = true
  end

  chain :failing_with do |message|
    @expected_message = message
    @message_expected = true
  end

  chain :at do |*segments|
    @expected_path = segments
  end

  failure_message do |actual|
    next "expected a decoder, got #{description_of(actual)}" unless actual.respond_to?(:call)

    "expected the decoder to #{description}, but #{describe_outcome(Decoding.decode(actual, input))}"
  end

  failure_message_when_negated do |actual|
    next "expected a decoder, got #{description_of(actual)}" unless actual.respond_to?(:call)

    "expected the decoder not to decode #{description_of(input)}"
  end

  description do
    if message_expected?
      next "fail decoding #{description_of(input)} with #{description_of(@expected_message)}#{render_path(expected_path)}"
    end
    next "decode #{description_of(input)} to #{description_of(@expected_value)}" if value_expected?

    "decode #{description_of(input)}"
  end

  def message_expected? = @message_expected
  def value_expected? = @value_expected

  def matches_failure?(result)
    return false unless result.err?

    msg, path = describe_failure(result)
    matches_value?(@expected_message, msg) && path_matches?(path)
  end

  def describe_outcome(result)
    unless result.ok?
      msg, path = describe_failure(result)
      return "it failed with #{description_of(msg)}#{render_path(path)}"
    end

    return "it succeeded with #{description_of(result.unwrap!)}" if message_expected?

    "it decoded to #{description_of(result.unwrap!)}"
  end
end
