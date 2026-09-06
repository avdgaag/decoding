# Decoding

Decoding is a library to help transform unknown external data into neat values with known shapes.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add decoding

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install decoding

## Usage

Decoding is a library to help transform unknown external data into neat values with known shapes. Consider calling an HTTP API: you might pull in whatever value. After passing it through decoder, you will have a value with a known shape -- or a sensible error message.

For example, call an API to get some JSON value:

```ruby
body = JSON.parse(Net::HTTP.get("https://api.placeholderjson.dev/shipments/7EBWXB5"))
```

How do you safely work with `body`? If parsing the response body as JSON has worked, you know you have some kind of Ruby value -- but you're not sure of its structure. This can lead to cryptic error messages far removing of making this HTTP call where values are of unexpected types, hashes turn out not to have certain keys or the nesting of data is different from what you expected.

Assume the response body, parsed as JSON, results in a value like this:

```ruby
{
  "orderID" => "7EBWXB5",
  "orderDate" => "1595674680",
  "estimatedDeliveryDate" => "1596365935",
  "deliveryDate" => nil,
  "delayed" => false,
  "status" => {
    "orderPlaced" => true,
    "orderShipped" => true,
    "outForDelivery" => true,
    "orderDelivered" => false
  }
}
```

We can use decoders to extract exactly those pieces from this payload that we need, making assertions along the way of what the data looks like and generating helpful errors when reality does not match our expectations.

For example, we could parse the above payload like so:

```ruby
Order = Data.define(:id, :date, :status)
D = Decoding::Decoders

time_decoder = D.map(D.string) { Time.at(_1.to_i) }
order_decoder = D.map(
  D.field("orderID", D.string),
  D.field("orderDate", time_decoder),
  D.field("status", D.hash(D.string, D.boolean))
) { |*args| Order.new(*args) }

Decoding.decode(order_decoder, body)
# => Decoding::Ok(#<data Order
  id: '7EBWXB5',
  date: 2020-07-25 12:58:00 +0200,
  status: {"orderPlaced"=>true,"orderShipped"=>true,"outForDelivery"=>true,"orderDelivered"=>false}>)
```

Decoders take an input value and generate an output value from it. There are decoders for basic Ruby types, compound types such as arrays and hashes, decoders for trying out various decoders and, finally, there is the `map` decoder for decoding one or more output values from a given input value and applying a transformation to them with a block. All these decoders can be composed together into new, more complex decoders.

A decoder is, in essence, a function that returns a result based on an input value. Consider how, roughly, the `string` decoder is implemented:

```ruby
string_decoder = ->(input_value) do
  if input_value.is_a?(String)
    Decoding::Result.ok(input_value)
  else
    Decoding::Result.err("expected String, got #{input_value.class}")
  end
end
```

You can use the base decoders along with `map` to write more complex decoder. For example, you could extract a `time_decoder` from the example above:

```ruby
time_decoder = D.map(D.string) { Time.at(_1.to_i) }
```

When the shape of the incoming data is unknown, you can try out various decoders in a row to find the first that succeeds using `any`:

```ruby
string_or_integer = D.any(D.string, D.integer)
Decoding.decode(string_or_integer, 1) # => Decoding::Ok(1)
Decoding.decode(string_or_integer, '1') # => Decoding::Ok('1')
```

A value that might be absent is decoded with `optional`. It hands the value to the given decoder first, so that decoder can give `nil` a meaning of its own, and only falls back to `nil` when the decoder cannot handle it:

```ruby
optional_name = D.optional(D.string)
Decoding.decode(optional_name, "John") # => Decoding::Ok("John")
Decoding.decode(optional_name, nil) # => Decoding::Ok(nil)
Decoding.decode(optional_name, 123) # => Decoding::Err("expected String, got Integer")
```

Note how the failure is the one reported by the given decoder: since you asked for an optional string, being told the value was not `nil` either adds nothing.

Decoders that refer to themselves need `lazy`, which defers building the decoder until there is a value to decode. Without it, building the decoder would recurse endlessly:

```ruby
def tree
  D.decode_hash(
    name: D.field("name", D.string),
    children: D.field("children", D.array(D.lazy { tree }))
  )
end

Decoding.decode(tree, { "name" => "a", "children" => [{ "name" => "b", "children" => [] }] })
# => Decoding::Ok({ name: "a", children: [{ name: "b", children: [] }] })
```

You can also base one decoder on a previously decoded value. For example, a payload might contain a version number describing its format. Use `and_then` to decode one value and then construct a new decoder to run against the same input using that value:

```ruby
multiple_version_decoder = D.and_then(D.field("version", D.string)) do |version|
  if version == "1"
    D.field("name", D.string)
  else
    D.field("fullName", D.string)
  end
end
```

Now, you have a decoder that can work inputs using format version 1 and 2:

```ruby
Decoding.decode(multiple_version_decoder, "version" => "1", "name" => "John")
# => "John"
Decoding.decode(multiple_version_decoder, "version" => "2", "fullName" => "Paul")
# => "Paul"
```

The return values of decoding are `Decoding::Result` values, which come in `Ok` and `Err` subclasses. These describe how the decoding either succeeded or failed. The `Ok` values contain the decoded result, while the `Err` values always contain a string error message. It is up to you, as a developer, to decide how to deal with unsuccessful decoding.

When you would rather not handle failure explicitly, `decode!` returns the decoded value itself and raises `Decoding::UnwrapError` when decoding fails:

```ruby
Decoding.decode!(D.string, "foo") # => "foo"
Decoding.decode!(D.field("name", D.string), { "name" => 123 })
# raises Decoding::UnwrapError: Error at .name: expected String, got Integer
```

### Error messages

Decoders that reach into a value -- `field`, `at`, `array`, `index` and `hash` -- record where in the input the error occurred, so a failure deep inside a nested structure still tells you how to find it:

```ruby
Decoding.decode(D.at("a", "b", D.string), { "a" => { "b" => 1 } })
# => Decoding::Err("Error at .a.b: expected String, got Integer")
```

A decoder composed of other decoders reports the failures of the decoders it is built from, which is not always what a caller needs to know:

```ruby
id = D.any(D.integer, D.map(D.string, &:to_i))
Decoding.decode(id, true)
# => Decoding::Err("None of the decoders matched:\n  - expected Integer, got TrueClass\n  - expected String, got TrueClass")
```

Use `map_err` to give such a decoder a single error message of its own. The block receives the original message and the value being decoded, and returns the message to use instead:

```ruby
id = D.map_err(D.any(D.integer, D.map(D.string, &:to_i))) do |_message, value|
  "expected an ID, got #{value.inspect}"
end

Decoding.decode(id, true)
# => Decoding::Err("expected an ID, got true")
```

Replacing the message does not discard where the error occurred, so a decoder built this way still composes:

```ruby
Decoding.decode(D.field("id", id), { "id" => true })
# => Decoding::Err("Error at .id: expected an ID, got true")
```

## Available decoders

The following decoders are included:

* Basic types
    * `string`
    * `integer`
    * `float`
    * `numeric`
    * `nil`
    * `true`
    * `false`
    * `boolean`
    * `symbol`
    * `parsed_integer`
    * `parsed_float`
    * `parsed_boolean`
    * `regexp`
    * `match`
    * `enum`
* Utility decoders
    * `succeed`
    * `fail`
    * `original`
    * `map`
    * `map_err`
    * `decode_hash`
    * `and_then`
    * `lazy`
* Compound decoders
    * `any`
    * `optional`
    * `field`
    * `optional_field`
    * `array`
    * `index`
    * `hash`
    * `at`

### A note on `include`

Refer to the decoders through a short alias, as the examples above do:

```ruby
D = Decoding::Decoders
```

Do not `include Decoding::Decoders`. Several decoders are named after methods every object already has: `hash` would override `Object#hash`, leaving instances unusable as hash keys, and `fail` would shadow `Kernel#fail`, so raising an exception would silently build a decoder instead. In specs, `match` would shadow RSpec's `match` matcher. The decoders `nil`, `true` and `false` are unreachable as bare words in any case, since those are keywords.

### Optional decoders

Some decoders depend on parts of the standard library that not every application needs, so they are not loaded by default. Require them explicitly to make them available:

* `uri` -- decodes a `URI` object, or a string that can be parsed as one:

```ruby
require "decoding/decoders/uri"

Decoding.decode(D.uri, "https://example.com") # => Decoding::Ok(URI("https://example.com"))
Decoding.decode(D.uri, 123) # => Decoding::Err("expected a URI, got 123")
```

* `time` and `date` -- decode a `Time` or `Date` object, or a string in a given format. The format is either the name of a standard format or a `strptime` pattern:

```ruby
require "decoding/decoders/time"
require "decoding/decoders/date"

Decoding.decode(D.time(:iso8601), "2020-01-01T10:00:00Z") # => Decoding::Ok(2020-01-01 10:00:00 UTC)
Decoding.decode(D.date("%Y|%m"), "2020|01") # => Decoding::Ok(#<Date: 2020-01-01>)
Decoding.decode(D.date(:iso8601), "3rd Feb") # => Decoding::Err("expected a date in iso8601 format, got \"3rd Feb\"")
```

`time` accepts `:iso8601`, `:xmlschema`, `:rfc2822`, `:rfc822`, `:httpdate` and `:parse`; `date` also accepts `:rfc3339` and `:jisx0301`. There is deliberately no default: `:parse` is lenient and fills in whatever the input leaves out from the current time, so it has to be asked for by name.

* `big_decimal` -- decode a `BigDecimal` object, or a number or string describing one. Only finite numbers are accepted:

```ruby
require "decoding/decoders/big_decimal"

Decoding.decode(D.big_decimal, "1.23") # => Decoding::Ok(BigDecimal("1.23"))
Decoding.decode(D.big_decimal, 42) # => Decoding::Ok(BigDecimal("42"))
Decoding.decode(D.big_decimal, "abc") # => Decoding::Err("expected a decimal number, got \"abc\"")
```

This decoder needs the `bigdecimal` gem, which is no longer one of Ruby's default gems. Add `gem "bigdecimal"` to your Gemfile to use it.

## Reading configuration from the environment

Environment variables are always strings, and an application that is misconfigured should refuse to boot rather than fail later. `Decoding.env` reads a single variable, decodes it, and raises when it is missing or its value does not make sense:

```ruby
require "decoding/env"

Decoding.env("DATABASE_URL")                  # => "postgres://localhost/app"
Decoding.env("PORT", :integer)                # => 8080
Decoding.env("DEBUG", :boolean)               # => true
Decoding.env("PORT", :integer, default: 3000) # => 3000 when PORT is not set
```

The named types are `:string` (the default), `:symbol`, `:integer`, `:float` and `:boolean`. Any decoder is accepted too, which is how you read the types that live behind their own require:

```ruby
require "decoding/decoders/uri"

Decoding.env("DATABASE_URL", D.uri) # => #<URI::Generic postgres://localhost/app>
```

Failures name the variable, so the reason an application would not start is clear:

```
Decoding::UnwrapError: ENV["PORT"] is not set
Decoding::UnwrapError: ENV["PORT"]: expected an integer, got "abc"
```

A variable set to an empty string counts as set, so it still has to decode rather than quietly falling back to the default. To allow a variable to be absent without a default, give it a decoder that accepts `nil`:

```ruby
Decoding.env("SENTRY_DSN", D.optional(D.string)) # => nil when not set
```

Pass `from:` to read from somewhere other than `ENV`, which is useful in tests.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/avdgaag/decoding. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/avdgaag/decoding/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Decoding project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/avdgaag/decoding/blob/main/CODE_OF_CONDUCT.md).
