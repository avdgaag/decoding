# frozen_string_literal: true

# Matchers for asserting on decoders and their results, for applications that
# write decoders of their own.
#
# These are the matchers this gem tests itself with. Require them from your
# spec helper; they need `rspec-expectations`, which is not a dependency of
# this gem, so nothing is loaded unless you ask for it.
#
#     # spec/spec_helper.rb
#     require "decoding/rspec"
#
# `decode_value` describes a decoder, and is what you want most of the time: it
# runs the decoder for you, so an example says what a decoder does rather than
# how to call it.
#
#     expect(my_decoder).to decode_value({ "name" => "John" }).to({ name: "John" })
#     expect(my_decoder).to decode_value({}).failing_with(%(expected Hash with key "name"))
#     expect(my_decoder).to decode_value(nil)      # decodes; the value is not asserted
#     expect(my_decoder).not_to decode_value(nil)  # fails to decode
#
# An error nested in a structure is asserted with its location, outermost
# segment first, rather than by matching the rendered "Error at ." prefix:
#
#     expect(field("a", field("b", string)))
#       .to decode_value({ "a" => { "b" => 1 } })
#       .failing_with("expected String, got Integer").at("a", "b")
#
# `succeed_with` and `fail_with` describe a result you already have, for when
# making the call is part of what the example is testing:
#
#     expect(Decoding.decode(my_decoder, input)).to succeed_with({ name: "John" })
#     expect(Decoding.decode(my_decoder, input)).to fail_with("expected String, got Integer").at("name")
#
# Expected values are compared strictly, so `1` does not match `1.0` and a
# decoder answering with the wrong type cannot pass. Pass a matcher where that
# is too strict:
#
#     expect(unix_time).to decode_value("1595674680.5").to(an_object_having_attributes(usec: 500_000))
require_relative "../decoding"
require_relative "rspec/matcher_helpers"
require_relative "rspec/decode_value"
require_relative "rspec/succeed_with"
require_relative "rspec/fail_with"
