# frozen_string_literal: true

require_relative 'csi_code'

module TTYString
  class CSICode
    class A < TTYString::CSICode # leftovers:allow
      def action(rows = '1')
        rows = integer(rows)
        cursor.up(rows) if rows
      end
    end

    class B < TTYString::CSICode # leftovers:allow
      default_arg '1'

      def action(rows = '1')
        rows = integer(rows)
        cursor.down(rows) if rows
      end
    end

    class C < TTYString::CSICode # leftovers:allow
      default_arg 1

      def action(cols = '1')
        cols = integer(cols)
        cursor.right(cols) if cols
      end
    end

    class D < TTYString::CSICode # leftovers:allow
      default_arg '1'

      def action(cols = '1')
        cols = integer(cols)
        cursor.left(cols) if cols
      end
    end

    class E < TTYString::CSICode # leftovers:allow
      default_arg '1'

      def action(rows = '1')
        rows = integer(rows)
        return unless rows

        cursor.down(rows)
        cursor.col = 0
      end
    end

    class F < TTYString::CSICode # leftovers:allow
      default_arg '1'

      def action(rows = '1')
        rows = integer(rows)
        return unless rows

        cursor.up(rows)
        cursor.col = 0
      end
    end

    class G < TTYString::CSICode # leftovers:allow
      default_arg '1'

      def action(col = '1')
        col = integer(col)
        return unless col

        # cursor is zero indexed, arg is 1 indexed
        cursor.col = col - 1
      end
    end

    class H < TTYString::CSICode # leftovers:allow
      default_arg '1'

      def action(row = '1', col = '1')
        col = integer(col)
        row = integer(row)
        return unless col && row

        # cursor is zero indexed, arg is 1 indexed
        cursor.row = row - 1
        cursor.col = col - 1
      end
    end

    class LowH < TTYString::CSICode # leftovers:allow
      char('h')

      def action(code)
        case code
        when '?5', '?25', '?1004', '?1049', '?2004'
          # drop
        else
          parser.unknown
        end
      end
    end

    class LowF < TTYString::CSICode::H # leftovers:allow
      char 'f'
    end

    class J < TTYString::CSICode # leftovers:allow
      def action(mode = '0') # rubocop:disable Metrics/MethodLength
        case mode
        when '0' then screen.clear_forward
        when '1' then screen.clear_backward
        when '2', '3' then screen.clear
        else parser.unknown
        end
      end
    end

    class K < TTYString::CSICode # leftovers:allow
      def action(mode = '0') # rubocop:disable Metrics/MethodLength
        case mode
        when '0' then screen.clear_line_forward
        when '1' then screen.clear_line_backward
        when '2' then screen.clear_line
        else parser.unknown
        end
      end
    end

    class LowL < TTYString::CSICode::LowH # leftovers:allow
      char('l')
    end

    class LowM < TTYString::CSICode # leftovers:allow
      char 'm'

      def action(arg = '0', *args)
        screen.style(args.unshift(arg))
      end
    end

    class S < TTYString::CSICode # leftovers:allow
      def action(rows = '1')
        integer(rows)&.times { screen.scroll_up }
      end
    end

    class T < TTYString::CSICode # leftovers:allow
      def action(rows = '1')
        integer(rows)&.times { screen.scroll_down }
      end
    end

    class Tilde < TTYString::CSICode # leftovers:allow
      char('~')

      def action(arg)
        case arg
        when '200', '201'
          # bracketed paste
        else
          parser.unknown
        end
      end
    end

    class Unknown < TTYString::CSICode # leftovers:allow
      char(/[@-~]/)

      def action(*)
        parser.unknown
      end
    end
  end
end
