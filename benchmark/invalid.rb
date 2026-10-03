# frozen_string_literal: true

# Decode documents with errors in different places, to see what a failure
# costs and how much work happens after the first one. The plain Ruby baseline
# raises on the first error it finds, which is what the decoders could do too:
# they report only the first failure.
#
#   bundle exec ruby benchmark/invalid.rb
#   SIZE=1000 bundle exec ruby benchmark/invalid.rb

require "benchmark/ips"
require_relative "support"

def baseline(document)
  Benchmarks::Baseline.orders(document)
rescue ArgumentError
  nil
end

# The number of objects allocated by one run of the block.
def allocations
  before = GC.stat(:total_allocated_objects)
  yield
  GC.stat(:total_allocated_objects) - before
end

size = Benchmarks.size("SIZE", 100)
valid = Benchmarks::Fixture.parsed(size)
Benchmarks.verify!(valid)

scenarios = {
  "valid" => valid,
  "first order invalid" => Benchmarks::Fixture.invalidate(valid, [0]),
  "last order invalid" => Benchmarks::Fixture.invalidate(valid, [size - 1]),
  "every order invalid" => Benchmarks::Fixture.invalidate(valid, (0...size).to_a)
}

Benchmarks.header("Decoding #{size} orders with errors")

scenarios.each do |name, document|
  next if name == "valid"

  result = Decoding.decode(Benchmarks::ORDERS, document)
  abort "#{name}: expected the decoders to fail" if result.ok?
  abort "#{name}: expected the baseline to fail" if baseline(document)
  puts format("%-20s %s", name, result.unwrap_err(nil))
end

puts
puts format("%-20s %10s %10s", "Objects allocated", "decoders", "baseline")
scenarios.each do |name, document|
  decoders = allocations { Benchmarks::ORDERS.call(document) }
  plain = allocations { baseline(document) }
  puts format("%-20s %10d %10d", name, decoders, plain)
end
puts

Benchmark.ips do |x|
  x.config(warmup: 0.5, time: 1)
  scenarios.each do |name, document|
    x.report("decoders: #{name}") { Benchmarks::ORDERS.call(document) }
    x.report("baseline: #{name}") { baseline(document) }
  end
end
