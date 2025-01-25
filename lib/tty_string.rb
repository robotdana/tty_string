# frozen_string_literal: true

require_relative 'tty_string/parser'

# Renders a string taking into ANSI escape codes and \t\r\n etc
# Usage: TTYString.parse("This\r\e[KThat") => "That"
module TTYString
  class Error < StandardError; end
  class UnknownCodeError < Error; end

  RENDER = :render
  RAISE = :raise
  DROP = :drop

  UNKNOWN_OPTIONS = [RAISE, DROP].freeze
  private_constant :UNKNOWN_OPTIONS
  STYLE_OPTIONS = [RENDER, DROP].freeze
  private_constant :STYLE_OPTIONS

  class << self
    def parse(input_string, style: DROP, unknown: DROP) # rubocop:disable Metrics/MethodLength
      unless STYLE_OPTIONS.include?(style)
        raise ArgumentError, '`style:` must be either TTYString::RENDER or TTYString::DROP (default)'
      end
      unless UNKNOWN_OPTIONS.include?(unknown)
        raise ArgumentError, '`unknown:` must be either TTYString::RAISE or TTYString::DROP (default)'
      end

      Parser.new(input_string).render(style: style, unknown: unknown)
    end

    def to_proc
      method(:parse).to_proc
    end
  end
end
