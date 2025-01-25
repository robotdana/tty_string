# frozen_string_literal: true

module TTYString
  class Row
    include Enumerable

    attr_accessor :newline_style

    def initialize(newline_style: NullStyle)
      @array = []
      self.newline_style = newline_style
    end

    def each(&block)
      @array.each(&block)
    end

    def []=(index, value)
      @array[index] = value
    end

    def slice!(*args)
      @array.slice!(*args)
    end

    def fill(*args)
      @array.fill(*args)
    end
  end
end
