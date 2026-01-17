# frozen_string_literal: true

require_relative "../../../lib/decoding/decoders"
require_relative "../../../lib/decoding/decoders/match"
require_relative "../../../lib/decoding/decoders/map"

module Decoding
  module Decoders
    RSpec.describe Map do
      it "transforms a successfully decoded value with a block" do
        int = Match.new(Integer)
        map = Map.new(int) { _1 * 2 }
        expect(map.call(4)).to eql(Result.ok(8))
      end

      it "does not alter a failed decoding" do
        int = Match.new(Integer)
        map = Map.new(int) { _1 * 2 }
        expect(map.call("foo")).to be_err
      end

      it "can decode using multiple decoders, yielding multiple values" do
        decoder = Map.new(
          Decoders.field("id", Decoders.integer),
          Decoders.field("name", Decoders.string),
          Decoders.field("admin", Decoders.boolean)
        ) { |id, name, admin| [id, name, admin] }
        input = {
          "id" => 1,
          "name" => "Ringo",
          "admin" => false
        }
        expect(Decoding.decode(decoder, input)).to eql(Result.ok([1, "Ringo", false]))
      end

      it "fails if any of the multiple decoders fail" do
        decoder = Map.new(
          Decoders.field("id", Decoders.integer),
          Decoders.field("name", Decoders.integer),
          Decoders.field("admin", Decoders.boolean)
        ) { |id, name, admin| [id, name, admin] }
        input = {
          "id" => 1,
          "name" => "Ringo",
          "admin" => false
        }
        expect(Decoding.decode(decoder, input)).to eql(Result.err("Error at .name: expected Integer, got String"))
      end

      it "handles errors in the map block" do
        failing_decoder = Map.new(Decoders.integer) do |_value|
          raise StandardError, "block error"
        end
        expect(Decoding.decode(failing_decoder, 42))
          .to eql(Result.err("error in map block: block error"))
      end
    end
  end
end
