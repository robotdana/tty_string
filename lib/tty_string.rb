# frozen_string_literal: true

require_relative 'tty_string/parser'

# Renders a string taking into ANSI escape codes and \t\r\n etc
# Usage: TTYString.new("This\r\e[KThat").to_s => "That"
class TTYString
  def initialize(input_string, clear_style: true)
    @parser = Parser.new(input_string)
    @parser.clear_style = clear_style
  end

  def to_s
    parser.render
  end

  private

  attr_reader :clear_style
  attr_reader :parser
end
