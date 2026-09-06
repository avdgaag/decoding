# frozen_string_literal: true

RSpec.describe "succeed_with matcher" do
  it "passes when the result is an Ok holding the given value" do
    expect(Decoding::Result.ok("foo")).to succeed_with("foo")
  end

  it "passes when the result is an Ok holding nil" do
    expect(Decoding::Result.ok(nil)).to succeed_with(nil)
  end

  it "distinguishes between values of different types that compare as equal" do
    expect(Decoding::Result.ok(1)).not_to succeed_with(1.0)
  end

  it "composes with other matchers" do
    expect(Decoding::Result.ok("foo")).to succeed_with(a_string_matching(/fo/))
  end

  it "fails when the result is an Err" do
    expect { expect(Decoding::Result.err("boom")).to succeed_with("foo") }
      .to raise_error(RSpec::Expectations::ExpectationNotMetError, 'expected the result to succeed with "foo", but it failed with "boom"')
  end

  it "fails when the result is an Ok holding a different value" do
    expect { expect(Decoding::Result.ok("bar")).to succeed_with("foo") }
      .to raise_error(RSpec::Expectations::ExpectationNotMetError,
                      'expected the result to succeed with "foo", but it succeeded with "bar"')
  end

  it "fails when given something other than a result" do
    expect { expect("foo").to succeed_with("foo") }
      .to raise_error(RSpec::Expectations::ExpectationNotMetError, 'expected a Decoding::Result, got "foo"')
  end

  it "passes when negated and the result is an Err" do
    expect(Decoding::Result.err("boom")).not_to succeed_with("foo")
  end

  it "fails when negated and the result succeeds with the given value" do
    expect { expect(Decoding::Result.ok("foo")).not_to succeed_with("foo") }
      .to raise_error(RSpec::Expectations::ExpectationNotMetError, 'expected the result not to succeed with "foo"')
  end
end
