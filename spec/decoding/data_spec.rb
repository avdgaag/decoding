# frozen_string_literal: true

require_relative "../../lib/decoding"
require_relative "../../lib/decoding/decoders"
require_relative "../../lib/decoding/data"

module Decoding
  RSpec.describe Decoders do
    include Decoding
    include Decoders

    it "defines a new data class" do
      user_class = Decoding::Data.define(id: field("id", integer))
      user = user_class.new(id: 1)
      expect(user.id).to be(1)
    end

    it "can still define methods using a block" do
      user_class = Decoding::Data.define(id: field("id", integer)) do
        def greet
          "Hello, my id is #{id}."
        end
      end
      user = user_class.new(id: 1)
      expect(user.greet).to eql("Hello, my id is 1.")
    end

    it "can decode a value" do
      user_class = Decoding::Data.define(id: field("id", integer))
      Decoding.decode(user_class.decoder, { "id" => 123 }) => Decoding::Ok(user)
      expect(user.id).to be(123)
    end

    it "fails like a normal decoder" do
      user_class = Decoding::Data.define(id: field("id", integer))
      Decoding.decode(user_class.decoder, { "name" => "John" }) => Decoding::Err(msg)
      expect(msg).to eql(%(expected Hash with key "id"))
    end

    it "assigning to a constant still works" do
      stub_const("MyUser", Decoding::Data.define(id: field("id", integer)))
      Decoding.decode(MyUser.decoder, { "id" => 123 }) => Decoding::Ok(user)
      expect(user.inspect).to eql("#<data MyUser id=123>")
    end
  end
end
