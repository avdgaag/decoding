## [Unreleased]

* Add a `zone:` argument to the `time` and `unix_time` decoders, for resolving times somewhere other than the system's time zone. Anything answering the format you name will do, such as an `ActiveSupport::TimeZone`; a zone that cannot parse the format is refused when the decoder is built.
* Treat a parser answering with `nil` as a failure to decode, rather than as a successfully decoded `nil`. `ActiveSupport::TimeZone#parse` does this where every method of `Time` raises.

## [0.4.0]

* Add `uri` decoder for URI objects and strings that can be parsed as one, available after `require "decoding/decoders/uri"`
* Add `map_err` decoder for replacing the error message of a failed decoder
* Add `Decoding.decode!` for decoding a value, raising `Decoding::UnwrapError` when decoding fails
* Add `lazy` decoder, making recursive decoders possible
* Add `match` decoder for matching a value against any pattern using `===`
* Add `enum` decoder for a value that must be one of a fixed set of values
* Add `optional_field` decoder for a key that may be absent from a hash
* Add `time` and `date` decoders, available after `require "decoding/decoders/time"` and `require "decoding/decoders/date"`
* Add `big_decimal` decoder, available after `require "decoding/decoders/big_decimal"`
* Add `unix_time` decoder for timestamps, alongside the `time` decoder
* Add `parsed_integer`, `parsed_float` and `parsed_boolean` decoders for reading typed values out of strings
* Add `Decoding.env` for decoding a single environment variable, available after `require "decoding/env"`
* Raise `Decoding::UnwrapError` as a `Decoding::Error`
* Remove the unused `Decoding::Decoders::Index::Err` constant
* Report the location of errors nested inside a `hash` decoder as a path, like `field` and `array` do, rather than flattening it into the error message.
* Give the `boolean` decoder its own error message, rather than reporting the failures of the decoders it is built from
* Use consistent phrasing for the error messages of the `match`, `field`, `array` and `index` decoders
* Report the failure of the given decoder from the `optional` decoder, rather than also reporting that the value was not `nil`
* Report the location shared by all failures of an `any` decoder once, instead of repeating it in every collected message

## [0.3.0]

* Add `Decoding::Data` for creating decodable data classes

## [0.2.6]

* Add `Decoding::Result#unwrap!`

## [0.2.5]

* Report all error messages in the `any` decoder

## [0.2.4]

* Make `succeed` and `fail` proper, composable decoders
* Ensure different decoders use the same error values
* Turn exceptions in decoder blocks into errors
* Use immutable failure values as errors

## [0.2.3] - 2025-10-25

* Implement `Decoding::Result#deconstruct` to support pattern matching on result values.

## [0.2.2] - 2025-10-25

* Added `Result#unwrap_err`

## [0.2.1] - 2025-10-25

* Fixed missed error not returning `Decoding::Failure`

## [0.2.0] - 2025-10-25

* Added `decode_hash`, `regexp` and `original` decoders
* Fixed incorrect `Decoding::Failure` value comparisons
* Fixed some decoders incorrectly returning `String` values rather than
  `Decoding::Failure` values
* Bumped target Ruby version to 3.4.7

## [0.1.0] - 2024-05-08

- Initial release
