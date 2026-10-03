# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "yard"
require "rubocop/rake_task"

RSpec::Core::RakeTask.new(:spec)

RuboCop::RakeTask.new

YARD::Rake::YardocTask.new

task default: %i[spec rubocop yard]

BENCHMARKS = %w[realistic scaling invalid micro memory].freeze

namespace :bench do
  BENCHMARKS.each do |name|
    desc "Run benchmark/#{name}.rb"
    task(name) { ruby "benchmark/#{name}.rb" }
  end
end

desc "Run all benchmarks (see benchmark/README.md)"
task bench: BENCHMARKS.map { "bench:#{_1}" }
