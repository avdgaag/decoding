# frozen_string_literal: true

require_relative "../../../lib/decoding/decoders/pass"

module Decoding
  module Decoders
    RSpec.describe Pass do
      it "always succeeds with its input value" do
        expect(Pass.new).to decode_value("foo").to("foo")
      end
    end
  end
end
