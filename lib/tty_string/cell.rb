# frozen_string_literal: true

module TTYString
  class Cell
    attr_reader :style, :value

    def initialize(value, style: NullStyle)
      @style = style
      @value = value
    end
  end
end
