# frozen_string_literal: true

require 'strscan'
require_relative 'code_definitions'
require_relative 'csi_code_definitions'
require_relative 'style'
require_relative 'null_style'
require_relative 'screen'

module TTYString
  # Reads the text string a
  class Parser < StringScanner
    attr_reader :style_handler, :screen

    def render(style:, unknown:) # rubocop:disable Metrics/MethodLength
      @style_handler = style
      @unknown_handler = unknown

      reset
      @screen = Screen.new(initial_style: initial_style)
      read until eos?
      screen.to_s
    end

    def cursor
      screen.cursor
    end

    def unknown # rubocop:disable Metrics/MethodLength
      case unknown_handler
      when RAISE
        raise(
          UnknownCodeError,
          if block_given?
            yield(matched)
          else
            "Unknown code #{matched.inspect}"
          end
        )
      end
    end

    def initial_style
      @initial_style ||= case style_handler
      when RENDER then Style.new(parser: self)
      else NullStyle
      end
    end

    private

    attr_reader :unknown_handler

    def write(string)
      screen.write(string)
    end

    def read
      Code.descendants.any? { |c| c.render(self) } || default
    end

    def default
      write(getch)
    end
  end
end
