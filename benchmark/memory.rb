# frozen_string_literal: true

# Count the objects allocated while decoding the generated document, compared
# with the plain Ruby baseline, and show where the decoders allocate most.
#
#   bundle exec ruby benchmark/memory.rb
#   SIZE=500 TOP=20 bundle exec ruby benchmark/memory.rb

require "memory_profiler"
require_relative "support"

size = Benchmarks.size("SIZE", 100)
top = Benchmarks.size("TOP", 10)
document = Benchmarks::Fixture.parsed(size)
Benchmarks.verify!(document)

# Load everything that is loaded lazily, so it is not counted below.
Benchmarks::ORDERS.call(document)
Benchmarks::Baseline.orders(document)

decoders = MemoryProfiler.report { Benchmarks::ORDERS.call(document) }
baseline = MemoryProfiler.report { Benchmarks::Baseline.orders(document) }

Benchmarks.header("Allocations while decoding #{size} orders")

puts format("%-22s %14s %14s %12s", "", "objects", "bytes", "per order")
{ "decoders" => decoders, "plain Ruby baseline" => baseline }.each do |name, report|
  puts format(
    "%-22s %14d %14d %12d",
    name, report.total_allocated, report.total_allocated_memsize, report.total_allocated / size
  )
end

lib = File.expand_path("../lib", __dir__)

puts
puts "Objects allocated by the decoders, by class:"
decoders.allocated_objects_by_class.first(top).each do |stat|
  puts format("%14d  %s", stat[:count], stat[:data])
end

puts
puts "Objects allocated by the decoders, by line in lib/:"
decoders.allocated_objects_by_location.select { _1[:data].start_with?(lib) }.first(top).each do |stat|
  puts format("%14d  %s", stat[:count], stat[:data].delete_prefix("#{File.dirname(lib)}/"))
end
