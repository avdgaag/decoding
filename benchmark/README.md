# Benchmarks

Scripts for measuring how fast the decoders are and how much they allocate.
They are not part of the default `rake` task or CI: timings on shared CI
machines vary too much to compare. Run them by hand before and after a change
aimed at performance, and compare the output.

```sh
bundle exec rake bench            # all of them
bundle exec rake bench:realistic  # or one at a time
```

| Script         | What it shows                                                                                                                       |
| -------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| `realistic.rb` | Throughput decoding a generated API response listing orders, next to `JSON.parse` and the same work done in plain Ruby.            |
| `scaling.rb`   | Time per order as the document grows. If it rises with size, something is worse than linear.                                         |
| `micro.rb`     | Individual decoders in isolation, including failing input, to find which one is responsible for a slowdown.                         |
| `memory.rb`    | Objects allocated while decoding, compared with plain Ruby, and the lines in `lib/` that allocate most.                             |

## The test data

`support/fixture.rb` generates the document from a fixed seed, so every run
decodes the same data. Each order has nested objects, a list of order lines,
a free-form hash, an optional field, booleans, enums, decimals and a
timestamp, all as JSON would deliver them (string keys, and strings for
decimals and times). The document is parsed before timing starts, so only
decoding is measured.

`support/models.rb` holds the decoders under test and `Baseline`, a
hand-written decoder that checks the same things and builds the same objects.
Each script first checks that both give the same result. The ratio between
the two is the cost of the decoders on top of work that has to happen anyway.

## Options

Set these as environment variables:

- `SIZE`: number of orders, or the collection size in `micro.rb` (default 100)
- `SIZES`: comma-separated sizes for `scaling.rb` (default `100,200,400,800,1600`)
- `ONLY`: in `micro.rb`, run only scenarios whose name contains this text
- `TOP`: in `memory.rb`, how many classes and lines to list (default 10)

Turn on YJIT with `RUBY_YJIT_ENABLE=1`. The header of each report says
whether it was on.
