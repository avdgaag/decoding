## [Unreleased]

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
