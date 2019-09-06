class TTYString
  class Cursor
    attr_accessor :row, :col

    def initialize(row=0, col=0)
      @row = row
      @col = col
    end

    def row=(value)
      @row = value
      @row = 0 if @row < 0
    end

    def col=(value)
      @col = value
      @col = 0 if @col < 0
    end

    def left(n = 1)
      n = n.to_i
      raise ArgumentError unless n >= 0

      self.col -= n
    end

    def up(n = 1)
      n = n.to_i
      raise ArgumentError unless n >= 0

      self.row -= n
    end

    def down(n = 1)
      n = n.to_i
      raise ArgumentError unless n >= 0

      self.row += n
    end

    def right(n = 1)
      n = n.to_i
      raise ArgumentError unless n >= 0

      self.col += n
    end

    def to_ary
      [row, col]
    end
    alias_method :to_a, :to_ary
  end
end
