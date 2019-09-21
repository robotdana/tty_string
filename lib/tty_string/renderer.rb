# frozen_string_literal: true

require_relative 'screen'
class TTYString
  # turns the text string into screen instructions
  class Renderer
    attr_reader :screen

    def initialize
      @screen = Screen.new
    end

    def to_s
      screen.to_s
    end

    def write(string)
      screen.write(string)
    end

    # rubocop:disable Naming/MethodName
    def csi_A(rows = 1)
      cursor.up(rows)
    end

    def csi_B(rows = 1)
      cursor.down(rows)
    end

    def csi_C(cols = 1)
      cursor.right(cols)
    end

    def csi_D(cols = 1)
      cursor.left(cols)
    end

    def csi_E(rows = 1)
      cursor.down(rows)
      cursor.col = 0
    end

    def csi_F(rows = 1)
      cursor.up(rows)
      cursor.col = 0
    end

    def csi_G(col = 1)
      cursor.col = col.to_i - 1 # cursor is zero indexed, arg is 1 indexed
    end

    def csi_H(row = 1, col = 1)
      # cursor is zero indexed, arg is 1 indexed
      cursor.row = row.to_i - 1
      cursor.col = col.to_i - 1
    end
    alias csi_f csi_H

    def csi_J(mode = 0)
      case mode.to_i
      when 0 then screen.clear_forward
      when 1 then screen.clear_backward
      when 2, 3 then screen.clear
      end
    end

    def csi_K(mode = 0)
      case mode.to_i
      when 0 then screen.clear_line_forward
      when 1 then screen.clear_line_backward
      when 2 then screen.clear_line
      end
    end

    def csi_m(*args)
    end
    # rubocop:enable Naming/MethodName

    def slash_b
      cursor.left
      screen.clear_at_cursor
    end

    def slash_n
      cursor.down
      cursor.col = 0
      screen.write('')
    end

    def slash_r
      cursor.col = 0
    end

    def slash_t
      cursor.right(8 - (cursor.col % 8))
    end

    private

    def cursor
      screen.cursor
    end
  end
end
