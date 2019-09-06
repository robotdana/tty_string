# frozen_string_literal: true

require 'strscan'
require_relative 'tty_string/cursor'
require_relative 'tty_string/screen'

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

  def render # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/LineLength
    until scanner.eos?
      if scanner.peek(1) == "\b" # can't use scan because /\b/ matches everything.
        slash_b
        scanner.pos += 1
      elsif scanner.skip(/\n/) then slash_n
      elsif scanner.skip(/\r/) then slash_r
      elsif scanner.skip(/\t/) then slash_t
      elsif scanner.skip(/\e/) then slash_e
      elsif scanner.scan(/[^\e\r\n\t\b]+/)
        append_screen(scanner.matched)
      end
    end
  end

  private

  def slash_e
    return if scanner.eos?
    if scanner.skip(/\[/)
      args = []
      while scanner.scan(/\d+/)
        args << scanner.matched
        scanner.skip(/;/)
      end

      if scanner.scan(/[ABCDEFGHJKfm]/)
        send(:"csi_#{scanner.matched}", *args)
      else
        raise "unrecognised csi code \\e[#{args.join(';')}#{scanner.peek(1)}"
      end
    end
  end

  def csi_K(n = 0)
    case n.to_i
    when 0 then screen.clear_line_forward
    when 1 then screen.clear_line_backward
    when 2 then screen.clear_line
    else
      raise "unrecognised csi code \\e[#{n}K"
    end
  end

  def csi_m(*args)
    append_screen("\e[#{args.join(';')}m") unless ignore_color
  end

  def csi_A(n = 1)
    cursor.up(n)
  end

  def csi_B(n = 1)
    cursor.down(n)
  end

  def csi_C(n = 1)
    cursor.right(n)
  end

  def csi_D(n = 1)
    cursor.left(n)
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

  attr_reader :screen
  attr_reader :scanner
  attr_reader :ignore_color

  def cursor
    screen.cursor
  end

  def append_screen(string)
    string.each_char do |char|
      screen[cursor] = char
      cursor.right
    end
  end
end
