# frozen_string_literal: true

require_relative "../../../lib/decoding/decoders"
require_relative "../../../lib/decoding/decoders/match"
require_relative "../../../lib/decoding/decoders/map_err"

module Decoding
  module Decoders
    RSpec.describe MapErr do
      it "does not alter a successfully decoded value" do
        decoder = MapErr.new(Match.new(Integer)) { "expected a number" }
        expect(decoder.call(4)).to eql(Result.ok(4))
      end

      it "replaces the error message of a failed decoding" do
        decoder = MapErr.new(Match.new(Integer)) { "expected a number" }
        expect(Decoding.decode(decoder, "foo")).to eql(Result.err("expected a number"))
      end

      it "yields the original error message" do
        decoder = MapErr.new(Match.new(Integer)) { "sorry: #{_1}" }
        expect(Decoding.decode(decoder, "foo")).to eql(Result.err("sorry: expected Integer, got String"))
      end

      it "yields the input value" do
        decoder = MapErr.new(Match.new(Integer)) { |_msg, value| "expected a number, got #{value.inspect}" }
        expect(Decoding.decode(decoder, "foo")).to eql(Result.err('expected a number, got "foo"'))
      end

      it "retains the path of the original failure" do
        decoder = Decoders.array(MapErr.new(Decoders.string) { "expected a name" })
        expect(Decoding.decode(decoder, ["Ringo", 2])).to eql(Result.err("Error at .1: expected a name"))
      end

      it "handles errors in the map_err block" do
        decoder = MapErr.new(Decoders.integer) { raise StandardError, "block error" }
        expect(Decoding.decode(decoder, "foo"))
          .to eql(Result.err("error in map_err block: block error"))
      end
    end
  end
end
