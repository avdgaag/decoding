# frozen_string_literal: true

require_relative "../../lib/decoding"

module Decoding
  RSpec.describe Decoders do
    include Decoding
    include Decoders

    it "uses the decode function to decode a value using the given decoder" do
      expect(decode(string, "foo")).to succeed_with("foo")
    end

    it "matches string" do
      expect(string).to decode_value("foo").to("foo")
      expect(string).to decode_value(123).failing_with("expected String, got Integer")
    end

    it "matches integer" do
      expect(integer).to decode_value(123).to(123)
      expect(integer).to decode_value(0.5).failing_with("expected Integer, got Float")
      expect(integer).to decode_value(nil).failing_with("expected Integer, got NilClass")
    end

    it "matches float" do
      expect(float).to decode_value(123.0).to(123.0)
      expect(float).to decode_value(123).failing_with("expected Float, got Integer")
    end

    it "matches numeric" do
      expect(numeric).to decode_value(123.0).to(123.0)
      expect(numeric).to decode_value(123).to(123)
      expect(numeric).to decode_value(nil).failing_with("expected Numeric, got NilClass")
    end

    it "matches nil" do
      expect(self.nil).to decode_value(nil).to(nil)
      expect(self.nil).to decode_value(123).failing_with("expected NilClass, got Integer")
    end

    it "matches true" do
      expect(self.true).to decode_value(true).to(true)
      expect(self.true).to decode_value(false).failing_with("expected TrueClass, got FalseClass")
    end

    it "matches false" do
      expect(self.false).to decode_value(false).to(false)
      expect(self.false).to decode_value(true).failing_with("expected FalseClass, got TrueClass")
    end

    it "succeeds with a static value" do
      expect(succeed(456)).to decode_value(123).to(456)
    end

    it "fails with a static value" do
      expect(fail("456")).to decode_value(123).failing_with("456")
    end

    it "transforms a successfully decoded value with a block" do
      expect(map(string, &:upcase)).to decode_value("foo").to("FOO")
      expect(map(string, &:upcase)).not_to decode_value(123)
    end

    it "replaces the error message of a failed decoding with a block" do
      expect(map_err(string) { "expected a name" }).to decode_value("foo").to("foo")
      expect(map_err(string) { "expected a name" }).to decode_value(123).failing_with("expected a name")
    end

    it "decoders a value using the first matching of many decoders" do
      expect(any(string, integer)).to decode_value(123).to(123)
    end

    it "decodes any boolean value" do
      expect(boolean).to decode_value(true).to(true)
      expect(boolean).to decode_value(false).to(false)
      expect(boolean).to decode_value("yes").failing_with("expected true or false, got String")
    end

    it "decodes a value that may or may not be nil" do
      expect(optional(string)).to decode_value("foo").to("foo")
      expect(optional(string)).to decode_value(nil).to(nil)
    end

    it "decodes a field from a hash" do
      expect(field("id", integer)).to decode_value({ "id" => 123 }).to(123)
      expect(field("other", integer)).to decode_value({ "id" => 123 }).failing_with(%(expected Hash with key "other"))
      expect(field("id", string)).to decode_value({ "id" => 123 }).failing_with("expected String, got Integer").at("id")
      expect(field("id", integer)).to decode_value(123).failing_with("expected Hash, got Integer")
    end

    it "decodes a field that may be absent from a hash" do
      expect(optional_field("count", integer, default: 0)).to decode_value({}).to(0)
      expect(optional_field("count", integer, default: 0))
        .to decode_value({ "count" => "x" }).failing_with("expected Integer, got String").at("count")
    end

    it "decodes an array of values using a decoder" do
      expect(array(integer)).to decode_value([1, 2, 3]).to([1, 2, 3])
      expect(array(integer)).to decode_value([1, "2", 3]).failing_with("expected Integer, got String").at(1)
    end

    it "provides the path for a nested decoder" do
      decoder = array(field("a", array(field("b", integer))))
      expect(decoder).to decode_value([{ "a" => [{ "b" => 1 }] }]).to([[1]])
      expect(decoder)
        .to decode_value([{ "a" => [{ "b" => nil }] }])
        .failing_with("expected Integer, got NilClass").at(0, "a", 0, "b")
    end

    it "decodes a deeply nested data structure" do
      decoder = at("a", "b", "c", string)
      expect(decoder).to decode_value({ "a" => { "b" => { "c" => "1" } } }).to("1")
      expect(decoder)
        .to decode_value({ "a" => { "b" => { "c" => 1 } } })
        .failing_with("expected String, got Integer").at("a", "b", "c")
      expect(decoder).to decode_value(123).failing_with("expected Hash, got Integer")
    end

    it "decodes an array element by index using a decoder" do
      expect(index(0, integer)).to decode_value([1, 2, 3]).to(1)
    end

    it "decodes a hash using two decoders" do
      expect(hash(string, integer)).to decode_value({ "john" => 1 }).to({ "john" => 1 })
    end

    it "decodes a string to a symbol" do
      expect(symbol).to decode_value("foo").to(:foo)
    end

    it "decodes in two steps" do
      decoder = and_then(field("version", integer)) do |version|
        if version == 1
          field("name", string)
        else
          field("fullName", string)
        end
      end
      expect(decoder).to decode_value({ "version" => 1, "name" => "john" }).to("john")
      expect(decoder).to decode_value({ "version" => 2, "fullName" => "john" }).to("john")
    end

    it "decodes multiple decoders into a hash" do
      decoder = decode_hash({ id: field("id", integer), name: field("name", string) })
      expect(decoder).to decode_value({ "id" => 1, "name" => "John" }).to({ id: 1, name: "John" })
    end

    it "decodes into an empty hash given no decoders" do
      expect(decode_hash({})).to decode_value({ "id" => 1, "name" => "John" }).to({})
    end

    it "decodes values into themselves using original" do
      expect(original).to decode_value([1, 2, 3]).to([1, 2, 3])
    end

    it "matches a value against any pattern" do
      expect(match(Symbol)).to decode_value(:foo).to(:foo)
      expect(match(Symbol)).to decode_value("foo").failing_with("expected Symbol, got String")
    end

    it "decodes one of a fixed set of values" do
      expect(enum("active", "archived")).to decode_value("active").to("active")
      expect(enum(%w[active archived])).to decode_value("nope").failing_with(%(expected one of "active", "archived", got "nope"))
    end

    it "parses an integer out of a string" do
      expect(parsed_integer).to decode_value("8080").to(8080)
      expect(parsed_integer).to decode_value("08").to(8)
      expect(parsed_integer).to decode_value("0x1f").failing_with(%(expected an integer, got "0x1f"))
      expect(parsed_integer).to decode_value(8080).failing_with("expected an integer, got 8080")
    end

    it "parses a float out of a string" do
      expect(parsed_float).to decode_value("1.5").to(1.5)
      expect(parsed_float).to decode_value("1e3").to(1000.0)
      expect(parsed_float).to decode_value("abc").failing_with(%(expected a number, got "abc"))
    end

    it "parses a boolean out of a string" do
      expect(parsed_boolean).to decode_value("true").to(true)
      expect(parsed_boolean).to decode_value("false").to(false)
      expect(parsed_boolean).to decode_value("1").failing_with(%(expected "true" or "false", got "1"))
      expect(parsed_boolean).to decode_value(true).failing_with(%(expected "true" or "false", got true))
    end

    it "decodes values matching a regular expression" do
      expect(regexp(/o|a/)).to decode_value("foo").to("foo")
      expect(regexp("o|a")).to decode_value("foo").to("foo")
      expect(regexp(/o|a/)).to decode_value("qux").failing_with(%(expected value matching /o|a/, got "qux"))
      expect(regexp("o|a")).to decode_value("qux").failing_with(%(expected value matching /o|a/, got "qux"))
    end
  end
end
