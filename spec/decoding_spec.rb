# frozen_string_literal: true

RSpec.describe Decoding do
  it "has a version number" do
    expect(Decoding::VERSION).not_to be_nil
  end

  it "decodes a value using the given decoder" do
    expect(Decoding.decode(Decoding::Decoders.string, "foo")).to eql(Decoding::Result.ok("foo"))
  end

  it "unwraps a successful decoding with decode!" do
    expect(Decoding.decode!(Decoding::Decoders.string, "foo")).to eql("foo")
  end

  it "raises the error message of an unsuccessful decoding with decode!" do
    expect { Decoding.decode!(Decoding::Decoders.string, 123) }
      .to raise_error(Decoding::UnwrapError, "expected String, got Integer")
  end

  it "raises the location of an unsuccessful decoding with decode!" do
    decoder = Decoding::Decoders.field("name", Decoding::Decoders.string)
    expect { Decoding.decode!(decoder, { "name" => 123 }) }
      .to raise_error(Decoding::UnwrapError, "Error at .name: expected String, got Integer")
  end
end
