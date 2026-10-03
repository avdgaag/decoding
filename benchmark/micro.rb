# frozen_string_literal: true

# Measure individual decoders in isolation, to find out which one is
# responsible when the realistic benchmark slows down.
#
#   bundle exec ruby benchmark/micro.rb
#   SIZE=1000 bundle exec ruby benchmark/micro.rb
#   ONLY=array bundle exec ruby benchmark/micro.rb

require "benchmark/ips"
require_relative "support"
require_relative "../lib/decoding/decoders/date"
require_relative "../lib/decoding/decoders/uri"

D = Benchmarks::D
size = Benchmarks.size("SIZE", 100)
integers = Array.new(size) { _1 }
nested = (1..10).reverse_each.reduce("leaf") { |value, depth| { "level#{depth}" => value } }
record = (1..20).to_h { ["field#{_1}", _1] }

scenarios = {
  "integer" => [D.integer, 1],
  "boolean (false)" => [D.boolean, false],
  "big_decimal (string)" => [D.big_decimal, "12.34"],
  "big_decimal (float)" => [D.big_decimal, 12.34],
  "time(:iso8601)" => [D.time(:iso8601), "2026-10-03T12:00:00Z"],
  "unix_time (integer)" => [D.unix_time, 1_790_000_000],
  "date(:iso8601)" => [D.date(:iso8601), "2026-10-03"],
  "uri" => [D.uri, "https://example.com/orders?page=2"],
  "optional(string), given a string" => [D.optional(D.string), "foo"],
  "optional(string), given nil" => [D.optional(D.string), nil],
  "optional(big_decimal), given nil" => [D.optional(D.big_decimal), nil],
  "optional(time(:iso8601)), given nil" => [D.optional(D.time(:iso8601)), nil],
  "enum (4 values)" => [D.enum(Benchmarks::Fixture::STATUSES), "cancelled"],
  "any (5th of 5 matches)" => [D.any(D.nil, D.float, D.boolean, D.symbol, D.integer), 1],
  "field" => [D.field("field1", D.integer), record],
  "at (10 levels deep)" => [D.at(*(1..10).map { "level#{_1}" }, D.string), nested],
  "decode_hash (20 fields)" => [D.decode_hash(record.keys.to_h { [_1.to_sym, D.field(_1, D.integer)] }), record],
  "array(integer) x#{size}" => [D.array(D.integer), integers],
  "hash(string, integer) x#{size}" => [D.hash(D.string, D.integer), integers.to_h { ["key#{_1}", _1] }],
  "failing: array, last of #{size} invalid" => [D.array(D.integer), [*integers.drop(1), "x"]],
  "failing: array, all #{size} invalid" => [D.array(D.integer), integers.map(&:to_s)],
  "failing: any (none of 5 match)" => [D.any(D.nil, D.float, D.boolean, D.symbol, D.integer), "x"],
  "failing: missing field 10 levels deep" => [D.at(*(1..10).map { "level#{_1}" }, D.integer), nested]
}
scenarios.select! { |name, _| name.include?(ENV.fetch("ONLY")) } if ENV.key?("ONLY")

Benchmarks.header("Individual decoders")

Benchmark.ips do |x|
  x.config(warmup: 0.5, time: 1)
  scenarios.each do |name, (decoder, input)|
    x.report(name) { decoder.call(input) }
  end
end
