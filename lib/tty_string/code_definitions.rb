# frozen_string_literal: true

require_relative 'code'
require_relative 'csi_code'

module TTYString
  class Code
    class SlashA < TTYString::Code # leftovers:allow
      char "\a"
    end

    class SlashB < TTYString::Code # leftovers:allow
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

    class SlashN < TTYString::Code # leftovers:allow
      char "\n"

      def action
        cursor.down
        cursor.col = 0
        screen.ensure_row
      end
    end

    class SlashR < TTYString::Code # leftovers:allow
      char "\r"

      def action
        cursor.col = 0
      end
    end

    class SlashT < TTYString::Code # leftovers:allow
      char "\t"

      def action
        cursor.right(8 - (cursor.col % 8))
      end
    end
  end
end
