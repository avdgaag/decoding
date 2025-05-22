# frozen_string_literal: true

require_relative "decoding/version"
require_relative "decoding/decoders"

# Decoding is a library to help transform unknown external data into neat values
# with known shapes. Consider calling an HTTP API: you might pull in whatever
# value. After passing it through decoder, you will have a value with a known
# shape -- or a sensible error message.
#
# For example, call an API to get some JSON value:
#
#     body = JSON.parse(Net::HTTP.get("https://api.placeholderjson.dev/shipments/7EBWXB5"))
#
# How do you safely work with `body`? If parsing the response body as JSON has
# worked, you know you have some kind of Ruby value -- but you're not sure of
# its structure. This can lead to cryptic error messages far removing of making
# this HTTP call where values are of unexpected types, hashes turn out not to
# have certain keys or the nesting of data is different from what you expected.
#
# Assume the response body, parsed as JSON, results in a value like this:
#
#     {
#       "orderID" => "7EBWXB5",
#       "orderDate" => "1595674680",
#       "estimatedDeliveryDate" => "1596365935",
#       "deliveryDate" => null,
#       "delayed" => false,
#       "status" => {
#         "orderPlaced" => true,
#         "orderShipped" => true,
#         "outForDelivery" => true,
#         "orderDelivered" => false
#       }
#     }
#
# We can use decoders to extract exactly those pieces from this payload that we need,
# making assertions along the way of what the data looks like and generating helpful errors
# when reality does not match our expectations.
#
# For example, we could parse the above payload like so:
#
#     Order = Data.define(:id, :date, :status)
#     D = Decoding::Decoders
#     order_decoder = D.map(
#       D.field("orderID", D.string),
#       D.map(D.field("orderDate", D.string)) { Time.at(_1.to_i) },
#       D.hash(D.string, D.boolean)
#     ) { Order.new(*args) }
#     Decoding.decode(order_decoder, body)
#     # => Decoding::Ok(#<data Order
#       id: '7EBWXB5',
#       date: 2020-07-25 12:58:00 +0200,
#       status: {"orderPlaced"=>true,"orderShipped"=>true,"outForDelivery"=>true,"orderDelivered"=>false}>)
#
# Decoders take an input value and generate an output value from it. There are
# decoders for basic Ruby types, compound types such as arrays and hashes,
# decoders for trying out various decoders and, finally, there is the `map`
# decoder for decoding one or more output values from a given input value and
# applying a transformation to them with a block. All these decoders can be
# composed together into new, more complex decoders.
#
# A decoder is, in essence, a function that returns a result based on an input value. Consider
# how, roughly, the `string` decoder is implemented:
#
#     string_decoder = ->(input_value) do
#       if input_value.is_a?(String)
#         Decoding::Result.ok(input_value)
#       else
#         Decoding::Result.err("expected String, got #{input_value.class}")
#       end
#     end
#
# You can use the base decoders along with `map` to write more complex decoder. For example, you could
# extract a `time_decoder` from the example above:
#
#     time_decoder = D.map(D.string) { Time.at(_1.to_i) }
#
# When the shape of the incoming data is unknown, you can try out various
# decoders in a row to find the first that succeeds using `any`:
#
#     string_or_integer = D.any(D.string, D.integer)
#     Decoding.decode(string_or_integer, 1) # => Decoding::Ok(1)
#     Decoding.decode(string_or_integer, '1') # => Decoding::Ok('1')
#
# You can also base one decoder on a previously decoded value. For example, a
# payload might contain a version number describing its format. Use `and_then`
# to decode one value and then construct a new decoder to run against the same
# input using that value:
#
#     multiple_version_decoder = D.and_then(D.field("version", D.string)) do |version|
#       if version == "1"
#         D.field("name", D.string)
#       else
#         D.field("fullName", D.string)
#       end
#     end
#
# Now, you have a decoder that can work inputs using format version 1 and 2:
#
#     Decoding.decode(multiple_version_decoder, "version" => "1", "name" => "John")
#     # => "John"
#     Decoding.decode(multiple_version_decoder, "version" => "2", "fullName" => "Paul")
#     # => "Paul"
#
# The return values of decoding are `Decoding::Result` values, which come in
# `Ok` and `Err` subclasses. These describe how the decoding either succeeded or
# failed. The `Ok` values contain the decoded result, while the `Err` values
# always contain a string error message. It is up to you, as a developer, to
# decide how to deal with unsuccessful decoding.
module Decoding
  class Error < StandardError; end

  module_function

  # Run a given `decoder` on the given input `value`.
  #
  # @param decoder [Decoding::Decoder<a>]
  # @param value [Object]
  # @return [Decoding::Result<a>]
  def decode(decoder, value) = decoder.call(value).map_err(&:to_s)
end
