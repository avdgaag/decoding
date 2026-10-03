# frozen_string_literal: true

require_relative "../../../lib/decoding/decoders"
require_relative "../../../lib/decoding/decoders/optional"
require_relative "../../../lib/decoding/result"

module Decoding
  module Decoders
    RSpec.describe Optional do
      it "succeeds with the value decoded by the given decoder" do
        expect(Optional.new(Decoders.string)).to decode_value("foo").to("foo")
      end

      it "succeeds with nil given a nil value" do
        expect(Optional.new(Decoders.string)).to decode_value(nil).to(nil)
      end

      it "lets the given decoder decode a nil value first" do
        expect(Optional.new(Decoders.succeed(5))).to decode_value(nil).to(5)
      end

      it "stops asking the given decoder about nil once it has failed to decode it" do
        seen = []
        decoder = Optional.new(
          Decoders.map(Decoders.original) do |value|
            seen << value
            Integer(value)
          end
        )
        expect(decoder).to decode_value(nil).to(nil)
        expect(decoder).to decode_value(nil).to(nil)
        expect(decoder).to decode_value("1").to(1)
        expect(seen).to eql([nil, "1"])
      end

      it "keeps asking the given decoder about nil when it decodes it" do
        seen = []
        decoder = Optional.new(
          Decoders.map(Decoders.nil) do |value|
            seen << value
            5
          end
        )
        expect(decoder).to decode_value(nil).to(5)
        expect(decoder).to decode_value(nil).to(5)
        expect(seen).to eql([nil, nil])
      end

      it "reports the failure of the given decoder" do
        expect(Optional.new(Decoders.string)).to decode_value(123).failing_with("expected String, got Integer")
      end

      it "retains the path of a nested failure" do
        expect(Optional.new(Decoders.array(Decoders.integer)))
          .to decode_value([1, "x"]).failing_with("expected Integer, got String").at(1)
      end
    end
  end
end
