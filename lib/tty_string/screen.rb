# frozen_string_literal: true

require_relative 'cursor'
require_relative 'cell'
require_relative 'style'
require_relative 'row'

module TTYString
  # a grid to draw on
  class Screen
    attr_reader :cursor

    def initialize(initial_style:)
      @cursor = Cursor.new
      @screen = [Row.new(newline_style: initial_style)]
      @current_style = @initial_style = initial_style
    end

    def to_s # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      style_context = initial_style
      str = +''
      screen.each_with_index do |row, index|
        unless index.zero?
          str << row.newline_style.to_s(context: style_context) if row
          str << "\n"
          style_context = row.newline_style if row
        end

        Array(row).each do |cell|
          if cell
            str << cell.style.to_s(context: style_context)
            str << cell.value
            style_context = cell.style
          else
            str << ' '
          end
        end
      end
      str << current_style.to_s(context: style_context)
      str
    end

    def []=((row, col), value)
      screen[row] ||= Row.new(newline_style: current_style)
      screen[row][col] = value
    end

    def clear_at_cursor
      self[cursor] = Cell.new(' ', style: current_style)
    end

    def clear_line_forward
      screen[row].slice!(col..-1)
    end

    def clear_line_backward
      screen[row].fill(Cell.new(' ', style: current_style), 0..col)
    end

    def clear_line
      screen[row] = Row.new(newline_style: current_style)
    end

    def clear
      @screen = []
    end

    def scroll_up
      screen.push(Row.new(newline_style: current_style))
      screen.shift
    end

    def scroll_down
      screen.unshift(Row.new(newline_style: current_style))
      screen.pop
    end

    def clear_lines_before
      screen.fill(Row.new(newline_style: current_style), 0...row)
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
      screen[row] ||= Row.new(newline_style: current_style)
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
