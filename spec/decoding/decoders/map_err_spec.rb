# frozen_string_literal: true

require_relative "../../../lib/decoding/decoders"
require_relative "../../../lib/decoding/decoders/match"
require_relative "../../../lib/decoding/decoders/map_err"

module Decoding
  module Decoders
    RSpec.describe MapErr do
      it "does not alter a successfully decoded value" do
        expect(MapErr.new(Match.new(Integer)) { "expected a number" }).to decode_value(4).to(4)
      end

      it "replaces the error message of a failed decoding" do
        expect(MapErr.new(Match.new(Integer)) { "expected a number" }).to decode_value("foo").failing_with("expected a number")
      end

      it "yields the original error message" do
        expect(MapErr.new(Match.new(Integer)) { "sorry: #{_1}" })
          .to decode_value("foo").failing_with("sorry: expected Integer, got String")
      end

      it "yields the input value" do
        decoder = MapErr.new(Match.new(Integer)) { |_msg, value| "expected a number, got #{value.inspect}" }
        expect(decoder).to decode_value("foo").failing_with('expected a number, got "foo"')
      end

      it "retains the path of the original failure" do
        decoder = Decoders.array(MapErr.new(Decoders.string) { "expected a name" })
        expect(decoder).to decode_value(["Ringo", 2]).failing_with("expected a name").at(1)
      end

      it "handles errors in the map_err block" do
        decoder = MapErr.new(Decoders.integer) { raise StandardError, "block error" }
        expect(decoder).to decode_value("foo").failing_with("error in map_err block: block error")
      end
    end
  end
end
