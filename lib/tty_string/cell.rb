# frozen_string_literal: true

module TTYString
  class Cell
    attr_reader :style, :value

    def initialize(value, style: NullStyle)
      @style = style
      @value = value
    end

    def to_s(style_context: NullStyle)
      "#{style.to_s(context: style_context)}#{value}"
    end
  end
end
