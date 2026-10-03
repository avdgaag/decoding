# frozen_string_literal: true

# Decode a generated API response listing orders, and compare the decoders with
# the same work done by hand.
#
#   bundle exec ruby benchmark/realistic.rb
#   SIZE=1000 bundle exec ruby benchmark/realistic.rb

require "benchmark/ips"
require_relative "support"

size = Benchmarks.size("SIZE", 100)
json = Benchmarks::Fixture.json(size)
document = JSON.parse(json)
Benchmarks.verify!(document)

Benchmarks.header("Decoding #{size} orders (#{json.bytesize / 1024} KiB of JSON)")

Benchmark.ips do |x|
  x.config(warmup: 1, time: 3)
  x.report("JSON.parse (for scale)") { JSON.parse(json) }
  x.report("decoders") { Benchmarks::ORDERS.call(document) }
  x.report("plain Ruby baseline") { Benchmarks::Baseline.orders(document) }
  x.compare!
end
