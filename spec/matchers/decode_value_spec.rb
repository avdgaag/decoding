# frozen_string_literal: true

RSpec.describe "decode_value matcher" do
  let(:string) { Decoding::Decoders.string }
  let(:strings) { Decoding::Decoders.array(string) }

  it "passes when the decoder decodes the given input" do
    expect(string).to decode_value("foo")
  end

  it "passes when the decoder decodes the given input to the given value" do
    expect(Decoding::Decoders.map(string, &:upcase)).to decode_value("foo").to("FOO")
  end

  it "distinguishes between values of different types that compare as equal" do
    expect { expect(Decoding::Decoders.integer).to decode_value(1).to(1.0) }
      .to raise_error(RSpec::Expectations::ExpectationNotMetError, "expected the decoder to decode 1 to 1.0, but it decoded to 1")
  end

  it "composes with other matchers" do
    expect(string).to decode_value("foo").to(a_string_matching(/fo/))
  end

  it "passes when the decoder is expected to fail and does" do
    expect(strings).to decode_value([1]).failing_with("expected String, got Integer").at(0)
  end

  it "passes when negated and the decoder cannot decode the given input" do
    expect(string).not_to decode_value(123)
  end

  it "fails when the decoder cannot decode the given input" do
    expect { expect(string).to decode_value(123) }
      .to raise_error(RSpec::Expectations::ExpectationNotMetError,
                      'expected the decoder to decode 123, but it failed with "expected String, got Integer"')
  end

  it "fails when the decoder decodes the given input to a different value" do
    expect { expect(string).to decode_value("foo").to("FOO") }
      .to raise_error(RSpec::Expectations::ExpectationNotMetError,
                      'expected the decoder to decode "foo" to "FOO", but it decoded to "foo"')
  end

  it "fails when the decoder was expected to decode to a value but failed" do
    expect { expect(string).to decode_value(123).to("FOO") }
      .to raise_error(RSpec::Expectations::ExpectationNotMetError,
                      'expected the decoder to decode 123 to "FOO", but it failed with "expected String, got Integer"')
  end

  it "fails when the decoder was expected to fail but succeeded" do
    expect { expect(string).to decode_value("foo").failing_with("boom") }
      .to raise_error(RSpec::Expectations::ExpectationNotMetError,
                      'expected the decoder to fail decoding "foo" with "boom", but it succeeded with "foo"')
  end

  it "fails when the decoder fails at a different path" do
    expect { expect(strings).to decode_value([1]).failing_with("expected String, got Integer").at(1) }
      .to raise_error(RSpec::Expectations::ExpectationNotMetError,
                      'expected the decoder to fail decoding [1] with "expected String, got Integer" at .1, ' \
                      'but it failed with "expected String, got Integer" at .0')
  end

  it "fails when given something other than a decoder" do
    expect { expect("foo").to decode_value("foo") }
      .to raise_error(RSpec::Expectations::ExpectationNotMetError, 'expected a decoder, got "foo"')
  end

  it "fails when negated and given something other than a decoder" do
    expect { expect("foo").not_to decode_value("foo") }
      .to raise_error(RSpec::Expectations::ExpectationNotMetError, 'expected a decoder, got "foo"')
  end

  it "fails when negated and the decoder decodes the given input" do
    expect { expect(string).not_to decode_value("foo") }
      .to raise_error(RSpec::Expectations::ExpectationNotMetError, 'expected the decoder not to decode "foo"')
  end

  it "refuses to be negated when a value is expected" do
    expect { expect(string).not_to decode_value("foo").to("foo") }
      .to raise_error(ArgumentError, "use `not_to decode_value(input)` without `to` or `failing_with`")
  end

  it "refuses to be negated when a failure is expected" do
    expect { expect(string).not_to decode_value(123).failing_with("expected String, got Integer") }
      .to raise_error(ArgumentError, "use `not_to decode_value(input)` without `to` or `failing_with`")
  end
end
