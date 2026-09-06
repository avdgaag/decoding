# frozen_string_literal: true

require_relative "../../../lib/decoding/decoders"
require_relative "../../../lib/decoding/decoders/optional_field"
require_relative "../../../lib/decoding/result"

module Decoding
  module Decoders
    RSpec.describe OptionalField do
      it "decodes the value at the given key" do
        expect(OptionalField.new("count", Decoders.integer)).to decode_value({ "count" => 5 }).to(5)
      end

      it "succeeds with nil when the key is absent" do
        expect(OptionalField.new("count", Decoders.integer)).to decode_value({}).to(nil)
      end

      it "succeeds with the given default when the key is absent" do
        expect(OptionalField.new("count", Decoders.integer, default: 0)).to decode_value({}).to(0)
      end

      it "fails when the key is present but its value cannot be decoded" do
        expect(OptionalField.new("count", Decoders.integer, default: 0))
          .to decode_value({ "count" => "abc" }).failing_with("expected Integer, got String").at("count")
      end

      it "fails when the value is not a hash" do
        expect(OptionalField.new("count", Decoders.integer)).to decode_value(42).failing_with("expected Hash, got Integer")
      end

      it "decodes a nil value with the given decoder rather than using the default" do
        expect(OptionalField.new("count", Decoders.optional(Decoders.integer), default: 0))
          .to decode_value({ "count" => nil }).to(nil)
      end

      it "describes a record in which only some keys are required" do
        decoder = Decoders.decode_hash(
          name: Decoders.field("name", Decoders.string),
          nickname: Decoders.optional_field("nickname", Decoders.string)
        )
        expect(decoder).to decode_value({ "name" => "Ringo" }).to({ name: "Ringo", nickname: nil })
        expect(decoder)
          .to decode_value({ "name" => "Ringo", "nickname" => 123 })
          .failing_with("expected String, got Integer").at("nickname")
      end
    end
  end
end
