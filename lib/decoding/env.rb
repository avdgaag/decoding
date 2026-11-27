# frozen_string_literal: true

require_relative "../decoding"

# Decoding is a library to help transform unknown external data into neat values
# with known shapes.
module Decoding
  # The types {Decoding.env} accepts by name, mapped to the decoder that reads
  # them.
  #
  # Environment variables are always strings, so these are all decoders that
  # parse a string. Pass a decoder directly for anything else.
  ENV_TYPES = {
    string: :string,
    symbol: :symbol,
    integer: :parsed_integer,
    float: :parsed_float,
    boolean: :parsed_boolean
  }.freeze

  # Marks the absence of a default value, so that `nil` can be used as one.
  NO_DEFAULT = Object.new.freeze
  private_constant :NO_DEFAULT

  module_function

  # Read a single environment variable, decoding its value.
  #
  # This is meant for configuration read at boot time, such as a Rails
  # initializer: it returns the decoded value itself and raises when the
  # variable is missing or its value cannot be decoded, rather than letting a
  # misconfigured application start.
  #
  # @example
  #   Decoding.env("DATABASE_URL") # => "postgres://localhost/app"
  #   Decoding.env("PORT", :integer) # => 8080
  #   Decoding.env("PORT", :integer, default: 3000) # => 3000 when unset
  #   Decoding.env("DATABASE_URL", Decoders.uri) # => #<URI::Generic ...>
  # @param name [String] the name of the environment variable.
  # @param type [Symbol, Decoding::Decoder] one of the keys of {ENV_TYPES}, or
  #   any decoder to run against the value.
  # @param default [Object] returned, undecoded, when the variable is not set.
  # @param from [#key?, #fetch] where to read the variable from.
  # @raise [ArgumentError] when the type is not a known name or a decoder.
  # @raise [Decoding::UnwrapError] when the variable is missing or its value
  #   cannot be decoded.
  # @return [Object]
  def env(name, type = :string, default: NO_DEFAULT, from: ENV)
    decoder = env_decoder(type)
    return default if !from.key?(name) && !default.equal?(NO_DEFAULT)

    decode!(
      Decoders.map_err(decoder) do |message, value|
        value.nil? ? "ENV[#{name.inspect}] is not set" : "ENV[#{name.inspect}]: #{redact_env_value(message, value)}"
      end,
      from.fetch(name, nil)
    )
  end

  # Takes the value out of a decoder's error message, as an environment
  # variable can hold a secret (a password in a URL, a token in its query
  # string) that would otherwise end up in the logs of an application that
  # refused to start.
  #
  # Only a message in the form the built-in decoders use, `expected ..., got`
  # followed by the inspected value, keeps its description, with `[REDACTED]`
  # in place of the value, and only when that description does not contain the
  # value as well. Any other message is left out altogether, as there is no
  # telling which part of the value it shows. An empty value has nothing to
  # hide and stays visible.
  #
  # @private
  def redact_env_value(message, value)
    return message if value == ""

    shown = ", got #{value.inspect}"
    description = message.delete_suffix(shown)
    return "cannot be decoded; the value is not shown" unless message.start_with?("expected ") && message.end_with?(shown)
    return "cannot be decoded; the value is not shown" if [value.to_s, value.to_s.inspect[1..-2]].any? { description.include?(_1) }

    "#{description}, got [REDACTED]"
  end

  # @private
  def env_decoder(type)
    return type.to_decoder if type.respond_to?(:to_decoder)
    raise ArgumentError, "expected a type name or a decoder, got #{type.inspect}" unless type.is_a?(Symbol)
    raise ArgumentError, "unknown type: #{type.inspect}" unless ENV_TYPES.key?(type)

    Decoders.public_send(ENV_TYPES.fetch(type))
  end

  private_class_method :env_decoder, :redact_env_value
end
