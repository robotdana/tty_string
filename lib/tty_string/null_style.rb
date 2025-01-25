# frozen_string_literal: true

module TTYString
  class NullStyle
    class << self
      def new(*)
        self
      end

      def to_s(*)
        ''
      end
    end
  end
end
