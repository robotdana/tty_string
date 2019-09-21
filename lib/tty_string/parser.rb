# frozen_string_literal: true

require 'strscan'
require_relative 'renderer'

class TTYString
  # Reads the text string a
  class Parser < StringScanner
    def render(clear_style: true)
      reset
      @clear_style = clear_style
      @renderer = Renderer.new
      read until eos?
      renderer.to_s
    end

    private

    attr_reader :renderer
    attr_reader :clear_style

    def write(string)
      renderer.write(string)
    end

    def read
      text || slash_n || slash_r || slash_t || slash_b || slash_e
    end

    def text
      write(matched) if scan(text_regexp)
    end

    def slash_n
      renderer.slash_n if skip(/\n/)
    end

    def slash_r
      renderer.slash_r if skip(/\r/)
    end

    def slash_t
      renderer.slash_t if skip(/\t/)
    end

    def slash_b
      # can't use `scan(/\b/)` because it matches everything
      return unless peek(1) == "\b"

      self.pos += 1
      renderer.slash_b
    end

    def slash_e
      return unless scan(csi_regexp)

      args = matched.slice(2..-2).split(';')
      command = matched.slice(-1)
      render_csi(:"csi_#{command}", *args)
    end

    def csi_regexp
      @csi_regexp ||= Regexp.new("\e#{csi_pattern}")
    end

    def csi_pattern
      "\\[(\\d+;?|;)*[ABCDEFGHJKf#{'m' if clear_style}]"
    end

    def text_regexp
      @text_regexp ||= Regexp.new("[^\b\t\r\n\e]|\e(?!#{csi_pattern})")
    end

    def render_csi(method, *args)
      method = renderer.method(method)
      params = method.parameters
      args = args.take(params.length) unless params.assoc(:rest)
      args = [] if args.all?(&:empty?)
      method.call(*args)
    end
  end
end
