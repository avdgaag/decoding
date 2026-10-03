# frozen_string_literal: true

require_relative "support/fixture"
require_relative "support/models"

# Helpers shared by the benchmark scripts.
module Benchmarks
  module_function

  # Read a list of sizes from an environment variable, such as `SIZES=10,100`.
  def sizes(name, default)
    ENV.fetch(name, nil)&.split(",")&.map { Integer(_1.delete("_")) } || default
  end

  # Read a single size from an environment variable, such as `SIZE=1000`.
  def size(name, default) = sizes(name, [default]).first

  # The decoder and the baseline must agree, or the comparison means nothing.
  def verify!(document)
    expected = Baseline.orders(document)
    actual = Decoding.decode!(ORDERS, document)
    return if actual == expected

    abort "Decoder and baseline produce different results; fix that before benchmarking."
  end

  def header(title)
    puts
    puts title
    puts "=" * title.length
    puts "Ruby #{RUBY_VERSION}#{" +YJIT" if defined?(RubyVM::YJIT) && RubyVM::YJIT.enabled?}, decoding #{Decoding::VERSION}"
    puts
  end
end
