# frozen_string_literal: true

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
    end
  end
end
