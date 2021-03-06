# frozen_string_literal: true

require_relative 'csi_code'

class TTYString
  class CSICode
    class A < TTYString::CSICode # leftovers:allow
      def action(rows = 1)
        cursor.up(rows)
      end
    end

    class B < TTYString::CSICode # leftovers:allow
      def action(rows = 1)
        cursor.down(rows)
      end
    end

    class C < TTYString::CSICode # leftovers:allow
      def action(cols = 1)
        cursor.right(cols)
      end
    end

    class D < TTYString::CSICode # leftovers:allow
      def action(cols = 1)
        cursor.left(cols)
      end
    end

    class E < TTYString::CSICode # leftovers:allow
      def action(rows = 1)
        cursor.down(rows)
        cursor.col = 0
      end
    end

    class F < TTYString::CSICode # leftovers:allow
      def action(rows = 1)
        cursor.up(rows)
        cursor.col = 0
      end
    end

    class G < TTYString::CSICode # leftovers:allow
      def action(col = 1)
        # cursor is zero indexed, arg is 1 indexed
        cursor.col = col.to_i - 1
      end
    end

    class H < TTYString::CSICode # leftovers:allow
      def action(row = 1, col = 1)
        # cursor is zero indexed, arg is 1 indexed
        cursor.row = row.to_i - 1
        cursor.col = col.to_i - 1
      end
    end

    class LowH < TTYString::CSICode # leftovers:allow
      char(/\?2004h/)
    end

    class LowF < TTYString::CSICode::H # leftovers:allow
      char 'f'
    end

    class J < TTYString::CSICode # leftovers:allow
      default_arg 0

      def self.arg_re
        /[0-3]?/
      end

      def action(mode = 0)
        # :nocov: else won't ever be called. don't worry about it
        case mode
        # :nocov:
        when 0 then screen.clear_forward
        when 1 then screen.clear_backward
        when 2, 3 then screen.clear
        end
      end
    end

    class K < TTYString::CSICode # leftovers:allow
      default_arg 0

      def self.arg_re
        /[0-2]?/
      end

      def action(mode = 0)
        # :nocov: else won't ever be called. don't worry about it
        case mode
        # :nocov:
        when 0 then screen.clear_line_forward
        when 1 then screen.clear_line_backward
        when 2 then screen.clear_line
        end
      end
    end

    class LowL < TTYString::CSICode # leftovers:allow
      char(/\?2004l/)
    end

    class LowM < TTYString::CSICode # leftovers:allow
      char 'm'

      def self.arg_re
        # 0-255
        /(?:\d|\d\d|1\d\d|2[0-4]\d|25[0-5])?/
      end

      def self.render(renderer)
        super if renderer.clear_style
      end

      def action(*args); end
    end

    class S < TTYString::CSICode # leftovers:allow
      def action(rows = 1)
        rows.times { screen.scroll_up }
      end
    end

    class T < TTYString::CSICode # leftovers:allow
      def action(rows = 1)
        rows.times { screen.scroll_down }
      end
    end

    class Tilde < TTYString::CSICode # leftovers:allow
      char(/(?:200|201)~/)
    end
  end
end
