# frozen_string_literal: true

require_relative 'code'
require_relative 'csi_code'

class TTYString
  class Code
    class SlashA < TTYString::Code
      char "\a"
    end

    class SlashB < TTYString::Code
      char "\b"

      def self.match?(scanner)
        # can't use `scan(/\b/)` because it matches everything
        return false unless scanner.peek(1) == "\b"

        scanner.pos += 1
        true
      end

      def action
        cursor.left
        screen.clear_at_cursor
      end
    end

    class SlashN < TTYString::Code
      char "\n"

      def action
        cursor.down
        cursor.col = 0
        screen.write('')
      end
    end

    class SlashR < TTYString::Code
      char "\r"

      def action
        cursor.col = 0
      end
    end

    class SlashT < TTYString::Code
      char "\t"

      def action
        cursor.right(8 - (cursor.col % 8))
      end
    end
  end
end
