# frozen_string_literal: true

require "bigdecimal"
require "time"
require_relative "../../lib/decoding"
require_relative "../../lib/decoding/decoders/big_decimal"
require_relative "../../lib/decoding/decoders/time"

module Benchmarks
  D = Decoding::Decoders

  Customer = Decoding::Data.define(
    id: D.field("id", D.integer),
    name: D.field("name", D.string),
    email: D.field("email", D.regexp(/\A[^@\s]+@[^@\s]+\z/)),
    vip: D.field("vip", D.boolean)
  )

  Address = Decoding::Data.define(
    street: D.field("street", D.string),
    postal_code: D.field("postal_code", D.string),
    city: D.field("city", D.string),
    country: D.field("country", D.enum(Fixture::COUNTRIES))
  )

  Line = Decoding::Data.define(
    sku: D.field("sku", D.string),
    quantity: D.field("quantity", D.integer),
    unit_price: D.field("unit_price", D.big_decimal),
    tags: D.field("tags", D.array(D.string))
  )

  Order = Decoding::Data.define(
    id: D.field("id", D.integer),
    reference: D.field("reference", D.regexp(/\AORD-\d{6}\z/)),
    status: D.field("status", D.map(D.enum(Fixture::STATUSES), &:to_sym)),
    placed_at: D.field("placed_at", D.time(:iso8601)),
    total: D.field("total", D.big_decimal),
    currency: D.field("currency", D.enum(Fixture::CURRENCIES)),
    gift: D.field("gift", D.boolean),
    customer: D.field("customer", Customer),
    shipping_address: D.field("shipping_address", Address),
    lines: D.field("lines", D.array(Line)),
    metadata: D.field("metadata", D.hash(D.string, D.string)),
    note: D.optional_field("note", D.string)
  )

  # The decoder under test: the list of orders in the generated document.
  ORDERS = D.at("data", "orders", D.array(Order))

  # Decodes the same document into the same objects with plain Ruby, checking
  # the same things the decoders check. It shows what the decoders cost on top
  # of the work that has to happen anyway, and raises on the first problem
  # rather than reporting failures.
  module Baseline
    module_function

    def orders(document)
      document.fetch("data").fetch("orders").map { order(_1) }
    end

    def order(hash)
      Order.new(
        id: check(hash.fetch("id"), Integer),
        reference: check(hash.fetch("reference"), /\AORD-\d{6}\z/),
        status: enum(hash.fetch("status"), Fixture::STATUSES).to_sym,
        placed_at: Time.iso8601(check(hash.fetch("placed_at"), String)),
        total: decimal(hash.fetch("total")),
        currency: enum(hash.fetch("currency"), Fixture::CURRENCIES),
        gift: check(hash.fetch("gift"), true..true, false..false),
        customer: customer(hash.fetch("customer")),
        shipping_address: address(hash.fetch("shipping_address")),
        lines: check(hash.fetch("lines"), Array).map { line(_1) },
        metadata: check(hash.fetch("metadata"), Hash).each { |k, v| check(k, String) && check(v, String) },
        note: hash.key?("note") ? check(hash["note"], String) : nil
      )
    end

    def customer(hash)
      Customer.new(
        id: check(hash.fetch("id"), Integer),
        name: check(hash.fetch("name"), String),
        email: check(hash.fetch("email"), /\A[^@\s]+@[^@\s]+\z/),
        vip: check(hash.fetch("vip"), true..true, false..false)
      )
    end

    def address(hash)
      Address.new(
        street: check(hash.fetch("street"), String),
        postal_code: check(hash.fetch("postal_code"), String),
        city: check(hash.fetch("city"), String),
        country: enum(hash.fetch("country"), Fixture::COUNTRIES)
      )
    end

    def line(hash)
      Line.new(
        sku: check(hash.fetch("sku"), String),
        quantity: check(hash.fetch("quantity"), Integer),
        unit_price: decimal(hash.fetch("unit_price")),
        tags: check(hash.fetch("tags"), Array).each { check(_1, String) }
      )
    end

    def check(value, *patterns)
      return value if patterns.any? { _1 === value }

      raise ArgumentError, "unexpected #{value.inspect}"
    end

    def enum(value, values)
      values.include?(value) ? value : raise(ArgumentError, "unexpected #{value.inspect}")
    end

    def decimal(value)
      BigDecimal(check(value, String, Integer, Float)).tap do |number|
        raise ArgumentError, "not a finite number" unless number.finite?
      end
    end
  end
end
