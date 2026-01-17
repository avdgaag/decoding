# frozen_string_literal: true

require_relative "../../../lib/decoding/decoders"
require_relative "../../../lib/decoding/decoders/and_then"
require_relative "../../../lib/decoding/result"

module Decoding
  module Decoders
    RSpec.describe AndThen do
      let(:decoder) do
        AndThen.new(Decoders.field("version", Decoders.integer)) do |value|
          if value == 1
            Decoders.field("name", Decoders.string)
          else
            Decoders.field("fullName", Decoders.string)
          end
        end
      end

      it "succeeds using the given decoder" do
        expect(Decoding.decode(decoder, "version" => 1, "name" => "John")).to eql(Result.ok("John"))
        expect(Decoding.decode(decoder, "version" => 2, "fullName" => "John")).to eql(Result.ok("John"))
      end

      it "fails when the first decoder does not match" do
        expect(Decoding.decode(decoder, "version" => "1", "name" => "John"))
          .to eql(Result.err("Error at .version: expected Integer, got String"))
      end

      it "fails when the second decoder does not match" do
        expect(Decoding.decode(decoder, "version" => 1, "name" => 123))
          .to eql(Result.err("Error at .name: expected String, got Integer"))
      end

      it "handles errors in the and_then block" do
        failing_decoder = AndThen.new(Decoders.integer) do |_value|
          raise StandardError, "block error"
        end
        expect(Decoding.decode(failing_decoder, 42))
          .to eql(Result.err("error in and_then block: block error"))
      end
    end
  end
end
