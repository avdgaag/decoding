# frozen_string_literal: true

require_relative "../../../lib/decoding/decoders"
require_relative "../../../lib/decoding/decoders/and_then"
require_relative "../../../lib/decoding/result"

module Decoding
  module Decoders
    RSpec.describe AndThen do
      subject(:decoder) do
        AndThen.new(Decoders.field("version", Decoders.integer)) do |value|
          if value == 1
            Decoders.field("name", Decoders.string)
          else
            Decoders.field("fullName", Decoders.string)
          end
        end
      end

      it "succeeds using the given decoder" do
        expect(decoder).to decode_value({ "version" => 1, "name" => "John" }).to("John")
        expect(decoder).to decode_value({ "version" => 2, "fullName" => "John" }).to("John")
      end

      it "fails when the first decoder does not match" do
        expect(decoder).to decode_value({ "version" => "1", "name" => "John" })
          .failing_with("expected Integer, got String").at("version")
      end

      it "fails when the second decoder does not match" do
        expect(decoder).to decode_value({ "version" => 1, "name" => 123 })
          .failing_with("expected String, got Integer").at("name")
      end

      it "handles errors in the and_then block" do
        failing_decoder = AndThen.new(Decoders.integer) do |_value|
          raise StandardError, "block error"
        end
        expect(failing_decoder).to decode_value(42).failing_with("error in and_then block: block error")
      end
    end
  end
end
