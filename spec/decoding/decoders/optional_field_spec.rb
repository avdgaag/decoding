# frozen_string_literal: true

require_relative "../../../lib/decoding/decoders"
require_relative "../../../lib/decoding/decoders/optional_field"
require_relative "../../../lib/decoding/result"

module Decoding
  module Decoders
    RSpec.describe OptionalField do
      it "decodes the value at the given key" do
        decoder = OptionalField.new("count", Decoders.integer)
        expect(decoder.call({ "count" => 5 })).to eql(Result.ok(5))
      end

      it "succeeds with nil when the key is absent" do
        decoder = OptionalField.new("count", Decoders.integer)
        expect(decoder.call({})).to eql(Result.ok(nil))
      end

      it "succeeds with the given default when the key is absent" do
        decoder = OptionalField.new("count", Decoders.integer, default: 0)
        expect(decoder.call({})).to eql(Result.ok(0))
      end

      it "fails when the key is present but its value cannot be decoded" do
        decoder = OptionalField.new("count", Decoders.integer, default: 0)
        expect(Decoding.decode(decoder, { "count" => "abc" }))
          .to eql(Result.err("Error at .count: expected Integer, got String"))
      end

      it "fails when the value is not a hash" do
        decoder = OptionalField.new("count", Decoders.integer)
        expect(Decoding.decode(decoder, 42)).to eql(Result.err("expected Hash, got Integer"))
      end

      it "decodes a nil value with the given decoder rather than using the default" do
        decoder = OptionalField.new("count", Decoders.optional(Decoders.integer), default: 0)
        expect(decoder.call({ "count" => nil })).to eql(Result.ok(nil))
      end

      it "describes a record in which only some keys are required" do
        decoder = Decoders.decode_hash(
          name: Decoders.field("name", Decoders.string),
          nickname: Decoders.optional_field("nickname", Decoders.string)
        )
        expect(Decoding.decode(decoder, { "name" => "Ringo" })).to eql(Result.ok({ name: "Ringo", nickname: nil }))
        expect(Decoding.decode(decoder, { "name" => "Ringo", "nickname" => 123 }))
          .to eql(Result.err("Error at .nickname: expected String, got Integer"))
      end
    end
  end
end
