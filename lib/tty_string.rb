# frozen_string_literal: true

require 'strscan'
require_relative 'tty_string/cursor'
require_relative 'tty_string/screen'

# Renders a string taking into ANSI escape codes and \t\r\n etc
# Usage: TTYString.new("this\r\e[Kthat").to_s => "that"
class TTYString
  def initialize(input_string, ignore_color: false)
    @scanner = StringScanner.new(input_string)
    @screen = Screen.new
    @ignore_color = ignore_color
  end

  def to_s
    render
    screen.to_s
  end

  private

  attr_reader :screen
  attr_reader :scanner
  attr_reader :ignore_color

  def render
    slash || rest until scanner.eos?
  end

  def rest
    screen.write(scanner.matched) if scanner.scan(/[^\e\r\n\t\b]+/)
  end

  def slash # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
    case scanner.peek(1)
    when "\b" then advance && slash_b
    when "\n" then advance && slash_n
    when "\r" then advance && slash_r
    when "\t" then advance && slash_t
    when "\e" then advance && slash_e
    end
  end

  def advance
    scanner.pos += 1
  end

  def slash_e # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    return if scanner.eos?

    return unless scanner.skip(/\[/)

    args = []
    while scanner.scan(/\d+/)
      args << scanner.matched
      scanner.skip(/;/)
    end

    if scanner.scan(/[ABCDEFGHJKfm]/)
      raise "unrecognised csi code \\e[#{args.join(';')}#{scanner.peek(1)}"
    end

    send(:"csi_#{scanner.matched}", *args)
  end

  # rubocop:disable Naming/MethodName
  def csi_K(mode = 0) # rubocop:disable Metrics/MethodLength
    case mode.to_i
    when 0 then screen.clear_line_forward
    when 1 then screen.clear_line_backward
    when 2 then screen.clear_line
    else raise "unrecognised csi code \\e[#{mode}K"
    end
  end

  def csi_m(*args)
    screen.write("\e[#{args.join(';')}m") unless ignore_color
  end

  def csi_A(lines = 1)
    cursor.up(lines)
  end

  def csi_B(lines = 1)
    cursor.down(lines)
  end

  def csi_C(chars = 1)
    cursor.right(chars)
  end

  def csi_D(chars = 1)
    cursor.left(chars)
  end

  def csi_E(lines = 1)
    cursor.down(lines)
    cursor.col = 0
  end

  def csi_F(lines = 1)
    cursor.up(lines)
    cursor.col = 0
  end
  # rubocop:enable Naming/MethodName

  def slash_b
    cursor.left
    screen.clear_at_cursor
  end

  def slash_n
    cursor.down
    cursor.col = 0
    screen[cursor] # for printing reasons
  end

  def slash_r
    cursor.col = 0
  end

  def slash_t
    cursor.right(8 - (cursor.col % 8))
  end

  def cursor
    screen.cursor
  end
end
