# frozen_string_literal: true

class TTYString
  # point on a screen. you can move it
  class Cursor
    attr_reader :row, :col

    def initialize(row = 0, col = 0)
      @row = row
      @col = col
    end

    def row=(value)
      @row = value
      @row = 0 if @row.negative?
    end

    def col=(value)
      @col = value
      @col = 0 if @col.negative?
    end

    def left(count = 1)
      raise ArgumentError if count.negative?

      self.col -= count
    end

    def up(count = 1)
      raise ArgumentError if count.negative?

      self.row -= count
    end

    def down(count = 1)
      raise ArgumentError unless count >= 0

      self.row += count
    end

    def right(count = 1)
      raise ArgumentError unless count >= 0

      self.col += count
    end

    def to_ary
      [row, col]
    end
    alias to_a to_ary
  end
end
