# frozen_string_literal: true

require_relative 'cursor'
require_relative 'cell'
require_relative 'style'

module TTYString
  # a grid to draw on
  class Screen
    attr_reader :cursor

    def initialize(initial_style:)
      @cursor = Cursor.new
      @screen = []
      @current_style = @initial_style = initial_style
    end

    def to_s # rubocop:disable Metrics/MethodLength
      style_context = initial_style
      screen.map do |row|
        Array(row).map do |cell|
          if cell
            value = cell.to_s(style_context: style_context)
            style_context = cell.style
            value
          else
            ' '
          end
        end.join.rstrip
      end.join("\n") + current_style.to_s(context: style_context)
    end

    def []=((row, col), value)
      screen[row] ||= []
      screen[row][col] = value
    end

    def clear_at_cursor
      self[cursor] = nil
    end

    def clear_line_forward
      screen[row].fill(nil, col..-1)
    end

    def clear_line_backward
      screen[row].fill(nil, 0..col)
    end

    def clear_line
      screen[row] = []
    end

    def clear
      @screen = []
    end

    def scroll_up
      screen.push([])
      screen.shift
    end

    def scroll_down
      screen.unshift([])
      screen.pop
    end

    def clear_lines_before
      screen.fill([], 0...row)
    end

    def clear_lines_after
      screen.slice!((row + 1)..-1)
    end

    def clear_backward
      clear_line_backward
      clear_lines_before
    end

    def clear_forward
      clear_lines_after
      clear_line_forward
    end

    def ensure_row
      screen[row] ||= []
    end

    def write(string)
      string.each_char do |char|
        self[cursor] = Cell.new(char, style: current_style)
        cursor.right
      end
    end

    def style(style_codes)
      self.current_style = current_style.new(style_codes)
    end

    private

    attr_reader :screen, :initial_style
    attr_accessor :current_style

    def row
      cursor.row
    end

    def col
      cursor.col
    end
  end
end
