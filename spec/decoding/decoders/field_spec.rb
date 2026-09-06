# frozen_string_literal: true

require_relative "../../../lib/decoding/decoders"
require_relative "../../../lib/decoding/decoders/field"
require_relative "../../../lib/decoding/result"

module Decoding
  module Decoders
    RSpec.describe Field do
      subject(:decoder) { Field.new("name", Decoders.string) }

      it "succeeds when given a hash with the given key and matching value" do
        expect(decoder).to decode_value({ "name" => "John" }).to("John")
      end

      it "fails when given a hash with the given key but non-matching value" do
        expect(decoder).to decode_value({ "name" => nil }).failing_with("expected String, got NilClass").at("name")
      end

      it "fails when given a hash without the given key" do
        expect(decoder).to decode_value({ "age" => 12 }).failing_with(%(expected Hash with key "name"))
      end

      it "fails when given something other than a hash" do
        expect(decoder).to decode_value(nil).failing_with("expected Hash, got NilClass")
      end
    end
  end
end
