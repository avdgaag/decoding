# frozen_string_literal: true

RSpec.describe "fail_with matcher" do
  it "passes when the result is an Err holding the given message" do
    expect(Decoding::Result.err("boom")).to fail_with("boom")
  end

  it "passes when the result is an Err holding a failure with the given message" do
    expect(Decoding::Result.err(Decoding::Failure.new("boom"))).to fail_with("boom")
  end

  it "passes when the failure occurred at the given path" do
    expect(Decoding::Result.err(Decoding::Failure.new("boom").push("name"))).to fail_with("boom").at("name")
  end

  it "reads nested paths outermost first" do
    failure = Decoding::Failure.new("boom").push(1).push("scores").push("data")
    expect(Decoding::Result.err(failure)).to fail_with("boom").at("data", "scores", 1)
  end

  it "understands failures that have already been converted to a string" do
    expect(Decoding::Result.err("Error at .0: boom")).to fail_with("boom").at(0)
  end

  it "composes with other matchers" do
    expect(Decoding::Result.err("boom")).to fail_with(a_string_matching(/oo/))
  end

  it "fails when the result is an Ok" do
    expect { expect(Decoding::Result.ok("bar")).to fail_with("boom") }
      .to raise_error(RSpec::Expectations::ExpectationNotMetError, 'expected the result to fail with "boom", but it succeeded with "bar"')
  end

  it "fails when the result failed with a different message" do
    expect { expect(Decoding::Result.err("bang")).to fail_with("boom") }
      .to raise_error(RSpec::Expectations::ExpectationNotMetError, 'expected the result to fail with "boom", but it failed with "bang"')
  end

  it "fails when the result failed at a different path" do
    expect { expect(Decoding::Result.err(Decoding::Failure.new("boom").push("b"))).to fail_with("boom").at("a") }
      .to raise_error(RSpec::Expectations::ExpectationNotMetError,
                      'expected the result to fail with "boom" at .a, but it failed with "boom" at .b')
  end

  it "fails when the result failed without a path" do
    expect { expect(Decoding::Result.err("boom")).to fail_with("boom").at("a") }
      .to raise_error(RSpec::Expectations::ExpectationNotMetError,
                      'expected the result to fail with "boom" at .a, but it failed with "boom"')
  end

  it "fails when given something other than a result" do
    expect { expect("boom").to fail_with("boom") }
      .to raise_error(RSpec::Expectations::ExpectationNotMetError, 'expected a Decoding::Result, got "boom"')
  end

  it "passes when negated and the result is an Ok" do
    expect(Decoding::Result.ok("bar")).not_to fail_with("boom")
  end

  it "fails when negated and the result fails with the given message" do
    expect { expect(Decoding::Result.err("boom")).not_to fail_with("boom") }
      .to raise_error(RSpec::Expectations::ExpectationNotMetError, 'expected the result not to fail with "boom"')
  end
end
