# frozen_string_literal: true

class TTYString
  # a grid to draw on
  class Screen
    attr_reader :cursor

    def initialize
      @cursor = Cursor.new
      @screen = []
    end

    def to_s
      screen.map { |c| Array(c).map { |x| x || ' ' }.join.rstrip }.join("\n")
    end

    def []=((row, col), *value)
      screen[row] ||= []
      screen[row][col] = value.flatten(1)
    end

    def []((row, col))
      screen[row] ||= []
      screen[row][col]
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

    def clear_lines_before
      screen.fill([], 0...row)
    end

    def clear_lines_after
      screen.fill([], (row + 1)..-1)
    end

    def write(string)
      string.each_char do |char|
        self[cursor] = char
        cursor.right
      end
    end

    private

    attr_reader :screen

    def row
      cursor.row
    end

    def col
      cursor.col
    end
  end
end
