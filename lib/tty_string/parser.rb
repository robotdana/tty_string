# frozen_string_literal: true

require 'strscan'
require_relative 'code_definitions'
require_relative 'csi_code_definitions'

require_relative 'screen'

class TTYString
  # Reads the text string a
  class Parser < StringScanner
    attr_accessor :clear_style
    attr_reader :screen

    def render
      reset
      @screen = Screen.new
      read until eos?
      screen.to_s
    end

    def cursor
      screen.cursor
    end

    private

    def write(string)
      screen.write(string)
    end

    def read
      TTYString::Code.descendants.any? { |c| c.render(self) } || default
    end

    def default
      write(getch)
    end
  end
end
