# frozen_string_literal: true

require 'strscan'
require_relative 'tty_string/cursor'
require_relative 'tty_string/screen'

# Renders a string taking into ANSI escape codes and \t\r\n etc
# Usage: TTYString.new("this\r\e[Kthat").to_s => "that"
class TTYString
  def initialize(input_string, clear_style: true)
    @scanner = StringScanner.new(input_string)
    @screen = Screen.new
    @clear_style = clear_style
  end

  def to_s
    render
    screen.to_s
  end

  private

  attr_reader :screen
  attr_reader :scanner
  attr_reader :clear_style

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

    if scanner.skip(/\[/)
      args = []
      if scanner.scan(/((\d+);?|;)*[ABCDEFGHJKfm]/)
        args = scanner.matched.split(';')
        cmd = args.last.slice!(-1)
        case cmd
        when 'H', 'f'
          send(:"csi_#{cmd}", *args.slice(0, 2).map { |x| x.empty? ? 1 : x.to_i })
        when 'm'
          csi_m(*args.reject(&:empty?).map(&:to_i)))
        else
          send(:"csi_#{cmd}", *args.slice(0, 1).reject(&:empty?).map(&:to_i))
        end
      else
        raise "unrecognised csi code \\e[#{args.join(';')}#{scanner.peek(1)}"
      end
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
    screen.write("\e[#{args.join(';')}m") unless clear_style
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

  def csi_E(n = 1)
    cursor.down(n)
    cursor.col = 0
  end

  def csi_F(n = 1)
    cursor.up(n)
    cursor.col = 0
  end

  def csi_G(n = 1)
    cursor.col = n - 1
  end

  def csi_H(n = 1, m = 1)
    cursor.row = n - 1
    cursor.col = m - 1
  end
  alias_method :csi_f, :csi_H

  def csi_J(n = 0)
    case n
    when 0
      screen.clear_lines_after
      screen.clear_line_forward
    when 1
      screen.clear_lines_before
      screen.clear_line_backward
    when 2, 3
      screen.clear
    end
  end

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
