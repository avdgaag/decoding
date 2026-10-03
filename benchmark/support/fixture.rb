# frozen_string_literal: true

require "json"

module Benchmarks
  # Generates a JSON document resembling an API response listing orders. The
  # same seed always produces the same document, so runs can be compared.
  module Fixture
    STATUSES = %w[pending paid shipped cancelled].freeze
    CURRENCIES = %w[EUR USD GBP].freeze
    COUNTRIES = %w[NL BE DE FR GB].freeze
    TAGS = %w[fragile gift sale new clearance bulk].freeze
    WORDS = %w[alpha bravo charlie delta echo foxtrot golf hotel india juliet].freeze

    module_function

    # @param size [Integer] the number of orders in the document
    # @param seed [Integer]
    # @return [String] the JSON document
    def json(size, seed: 1234)
      JSON.generate(document(size, Random.new(seed)))
    end

    # @return [Hash] the document as parsed from JSON, with string keys
    def parsed(size, seed: 1234)
      JSON.parse(json(size, seed:))
    end

    def document(size, random)
      {
        "data" => { "orders" => Array.new(size) { order(_1 + 1, random) } },
        "meta" => { "count" => size, "generated_at" => "2026-10-03T12:00:00Z" }
      }
    end

    def order(id, random)
      lines = Array.new(random.rand(1..5)) { line(random) }
      {
        "id" => id,
        "reference" => format("ORD-%06d", id),
        "status" => STATUSES.sample(random:),
        "placed_at" => Time.utc(2026, 1, 1).+(random.rand(0..(86_400 * 270))).iso8601,
        "total" => format("%.2f", lines.sum { _1["quantity"] * Float(_1["unit_price"]) }),
        "currency" => CURRENCIES.sample(random:),
        "gift" => random.rand < 0.1,
        "customer" => customer(random),
        "shipping_address" => address(random),
        "lines" => lines,
        "metadata" => WORDS.sample(random.rand(0..4), random:).to_h { [_1, word(random)] }
      }.tap { _1["note"] = "#{word(random)} #{word(random)}" if random.rand < 0.5 }
    end

    def customer(random)
      id = random.rand(1..100_000)
      {
        "id" => id,
        "name" => "#{word(random).capitalize} #{word(random).capitalize}",
        "email" => "customer#{id}@example.com",
        "vip" => random.rand < 0.2
      }
    end

    def address(random)
      {
        "street" => "#{word(random).capitalize}straat #{random.rand(1..300)}",
        "postal_code" => format("%04d AB", random.rand(1000..9999)),
        "city" => word(random).capitalize,
        "country" => COUNTRIES.sample(random:)
      }
    end

    def line(random)
      {
        "sku" => format("SKU-%05d", random.rand(1..99_999)),
        "quantity" => random.rand(1..10),
        "unit_price" => format("%.2f", random.rand(1.0..250.0)),
        "tags" => TAGS.sample(random.rand(0..3), random:)
      }
    end

    def word(random) = WORDS.sample(random:)
  end
end
