# frozen_string_literal: true

require_relative "../../../lib/decoding/decoders"
require_relative "../../../lib/decoding/decoders/any"
require_relative "../../../lib/decoding/result"

module Decoding
  module Decoders
    RSpec.describe Any do
      it "succeeds using the given decoder" do
        expect(Any.new(Decoders.string)).to decode_value("foo").to("foo")
      end

      it "succeeds using the first matching decoder if given multiple decoders" do
        expect(Any.new(Decoders.integer, Decoders.float, Decoders.string)).to decode_value("foo").to("foo")
      end

      it "fails when none of the decoders match, collecting all failure reasons" do
        expect(Any.new(Decoders.integer, Decoders.float, Decoders.string)).to decode_value(true).failing_with(
          "None of the decoders matched:\n  " \
          "- expected Integer, got TrueClass\n  " \
          "- expected Float, got TrueClass\n  " \
          "- expected String, got TrueClass"
        )
      end

      it "reports the location shared by all of its failures only once" do
        decoder = Any.new(Decoders.field("a", Decoders.string), Decoders.field("a", Decoders.integer))
        expect(decoder).to decode_value({ "a" => true }).failing_with(
          "None of the decoders matched:\n  " \
          "- expected String, got TrueClass\n  " \
          "- expected Integer, got TrueClass"
        ).at("a")
      end
    end
  end
end
