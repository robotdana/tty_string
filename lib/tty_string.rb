# frozen_string_literal: true

require_relative 'tty_string/parser'

# Renders a string taking into ANSI escape codes and \t\r\n etc
# Usage: TTYString.new("this\r\e[Kthat").to_s => "that"
class TTYString
  def initialize(input_string, clear_style: true)
    @parser = Parser.new(input_string)
    @clear_style = clear_style
  end

  def to_s
    parser.render(clear_style: clear_style)
  end

  private

  attr_reader :clear_style
  attr_reader :parser
end
