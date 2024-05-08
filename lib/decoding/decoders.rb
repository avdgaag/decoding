# frozen_string_literal: true

require_relative "decoders/match"
require_relative "result"

module Decoding
  module Decoders
    module_function

    def string = Decoders::Match.new(String)
    def integer = Decoders::Match.new(Integer)
    def float = Decoders::Match.new(Float)
    def numeric = Decoders::Match.new(Numeric)
    def nil = Decoders::Match.new(NilClass)
    def true = Decoders::Match.new(TrueClass)
    def false = Decoders::Match.new(FalseClass)
    def succeed(value) = ->(_) { Result.ok(value) }
    def fail(value) = ->(_) { Result.err(value) }
  end
end
