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
