## [Unreleased]

* Add `uri` decoder for URI objects and strings that can be parsed as one, available after `require "decoding/decoders/uri"`
* Add `map_err` decoder for replacing the error message of a failed decoder
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
