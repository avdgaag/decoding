# Decoding Gem - Instructions for Agentic Coding

## Project Overview

Ruby gem for decoding dynamic/external data into known structures. Functional-style decoder composition pattern. Min Ruby 3.3.

## Code Style & Standards

**Must follow:**
- Rubocop with rubocop-rspec, rubocop-performance, rubocop-rake
- Double quotes for strings
- Max line length: 140
- Frozen string literals
- Run `rake` (runs specs, rubocop, yard)

**Testing:**
- RSpec with SimpleCov
- Min coverage: 100% line, 100% branch
- Test file: `spec/<module>/<class>_spec.rb`
- Run with `COVERAGE=true bundle exec rspec`

## Architecture

**Core concepts:**
- Decoders are callables (`decoder.call(value)` → `Result`)
- `Result` has `Ok` and `Err` subclasses
- Immutable `Failure` class for error tracking
- Decoder composition via `map`, `and_then`, `any`
- Module `Decoding::Decoders` contains all decoders

**Key files:**
- `lib/decoding/decoder.rb` - decoder protocol
- `lib/decoding/result.rb` - result type
- `lib/decoding/failure.rb` - error tracking
- `lib/decoding/decoders.rb` - all decoder implementations
- `lib/decoding/decoders/*.rb` - individual decoders

## Common Tasks

**Add new decoder:**
1. Create `lib/decoding/decoders/<name>.rb` with callable returning Result
2. Add to `Decoders` module in `lib/decoding/decoders.rb`
3. Add spec in `spec/decoding/decoders/<name>_spec.rb`
4. Test success/failure cases
5. Run `rake` to verify

**Modify existing decoder:**
1. Read current implementation and spec first
2. Keep backward compatibility unless breaking change justified
3. Update specs for new behavior
4. Verify coverage remains at 100%

**Run tests:**
- All: `COVERAGE=true bundle exec rspec`
- Single file: `bundle exec rspec spec/path/to/spec.rb`
- CI tests Ruby 3.3, 3.4, 4.0

**Code quality:**
- Run `bundle exec rubocop` (auto-fix: `-a` or `-A`)
- Generate docs: `bundle exec yard`
- Check docs: `bundle exec yard server`

## Guidelines

- Decoders compose via functional patterns, avoid mutation
- Error messages should be descriptive
- Use `frozen_string_literal: true`
- Follow existing patterns in `lib/decoding/decoders/*.rb`
- Keep `Failure` immutable
- YARD docs for public methods
- Test edge cases (nil, empty, wrong types)

## Don't

- Break immutability of Result/Failure
- Add dependencies without justification
- Skip specs for new decoders
- Ignore Rubocop violations
- Add features without tests
