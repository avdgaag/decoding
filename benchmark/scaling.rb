# frozen_string_literal: true

# Decode documents of increasing size and report the time per order. When the
# time per order grows with the size of the document, decoding is worse than
# linear somewhere.
#
#   bundle exec ruby benchmark/scaling.rb
#   SIZES=100,1000 bundle exec ruby benchmark/scaling.rb

require_relative "support"

# Run the block repeatedly for about a second and return the fastest run in
# seconds. A block slower than that runs only once.
def fastest_run(budget: 1.0)
  runs = []
  started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  loop do
    t0 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    yield
    t1 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    runs << (t1 - t0)
    break if t1 - started >= budget
  end
  runs.min
end

sizes = Benchmarks.sizes("SIZES", [100, 200, 400, 800, 1_600])
Benchmarks.header("Scaling with document size")
puts format("%8s  %13s  %12s  %13s  %10s", "orders", "decoders", "per order", "baseline", "per order")

previous = nil
sizes.each do |size|
  document = Benchmarks::Fixture.parsed(size)
  Benchmarks.verify!(document) if size <= 1_000
  decoders = fastest_run { Benchmarks::ORDERS.call(document) }
  baseline = fastest_run { Benchmarks::Baseline.orders(document) }

  growth = previous && format("  (x%.1f size, x%.1f time)", size.fdiv(previous[0]), decoders / previous[1])
  puts format(
    "%8d  %10.2f ms  %9.1f µs  %10.2f ms  %7.1f µs%s",
    size, decoders * 1000, decoders * 1e6 / size, baseline * 1000, baseline * 1e6 / size, growth
  )
  previous = [size, decoders]
end
