# frozen_string_literal: true

require_relative "../../../lib/decoding/decoders"
require_relative "../../../lib/decoding/decoders/field"
require_relative "../../../lib/decoding/result"

module Decoding
  module Decoders
    RSpec.describe Field do
      it "succeeds when given a hash with the given key and matching value" do
        field = Field.new("name", Decoders.string)
        expect(field.call({ "name" => "John" })).to eql(Result.ok("John"))
      end

      it "fails when given a hash with the given key but non-matching value" do
        field = Field.new("name", Decoders.string)
        expect(field.call({ "name" => nil })).to eql(Result.err("expected value matching String, got: nil"))
      end

      it "fails when given a hash without the given key" do
        field = Field.new("name", Decoders.string)
        expect(field.call({ "age" => 12 })).to eql(Result.err("expected a Hash with key name"))
      end

      it "fails when given something other than a hash" do
        field = Field.new("name", Decoders.string)
        expect(field.call(nil)).to eql(Result.err("expected a Hash, got: nil"))
      end
    end
  end
end
