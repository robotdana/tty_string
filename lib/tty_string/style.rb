# frozen_string_literal: true

module TTYString
  class Style # rubocop:disable Metrics/ClassLength
    attr_reader :properties

    def initialize(style_codes = ['0'], parser:, properties: {})
      @properties = properties.dup
      @parser = parser
      parse_code(style_codes)
    end

    def new(style_codes)
      self.class.new(style_codes, properties: properties, parser: parser)
    end

    def to_s(context:)
      return '' if self == context

      values = properties.filter_map { |k, v| v if context.properties[k] != v }.uniq
      return '' if values.empty?

      "\e[#{values.join(';')}m"
    end

    private

    attr_reader :parser

    # delete then write to keep the order
    def set(*new_properties, code)
      new_properties.each do |property|
        properties.delete(property)
        properties[property] = code
      end
    end

    def slurp_color(enum, code)
      case (subcode = enum.next)
      when '2' then "#{code};#{subcode};#{color_param(enum)};#{color_param(enum)};#{color_param(enum)}"
      when '5' then "#{code};#{subcode};#{color_param(enum)}"
      else unknown(subcode)
      end
    end

    def color_param(enum)
      code = enum.next
      return unknown(code) unless code.match?(/\A\d*\z/)

      code_i = code.to_i
      return unknown(code) unless code_i < 256

      code_i
    end

    def unknown(style_code)
      parser.unknown { |code| "Unknown style code #{style_code.inspect} in #{code.inspect}" }
    end

    def parse_code(style_codes) # rubocop:disable Metrics/PerceivedComplexity, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/AbcSize
      enum = style_codes.each
      loop do # rubocop:disable Metrics/BlockLength
        case (code = enum.next)
        when '0'
          set(
            :background,
            :blink,
            :bold,
            :color,
            :conceal,
            :dim,
            :encircle,
            :font,
            :frame,
            :ideogram_overline,
            :ideogram_stress,
            :ideogram_underline,
            :italic,
            :overline,
            :vertical_position,
            :proportional,
            :reverse,
            :strike,
            :underline_color,
            :underline,
            :double_underline_or_not_bold,
            code
          )
        when '1'
          set(:bold, code)
        when '2'
          set(:dim, code)
        when '3'
          set(:italic, code)
        when '4', '24'
          set(:underline, code)
        when '5', '6', '25'
          set(:blink, code)
        when '7', '27'
          set(:reverse, code)
        when '8', '28'
          set(:conceal, code)
        when '9', '29'
          set(:strike, code)
        when '10'..'20'
          set(:font, code)
        when '21'
          set(:double_underline_or_not_bold, code)
        when '22'
          set(:bold, :dim, code)
        when '23'
          set(:font, :italic, code)
        when '26', '50'
          set(:proportional, code)
        when '30'..'37', '39', '90'..'97'
          set(:color, code)
        when '38'
          set(:color, slurp_color(enum, code))
        when '40'..'47', '49', '100'..'107'
          set(:background, code)
        when '48'
          set(:background, slurp_color(enum, code))
        when '51'
          set(:frame, code)
        when '52'
          set(:encircle, code)
        when '53', '55'
          set(:overline, code)
        when '54'
          set(:frame, :encircle, code)
        when '58'
          set(:underline_color, slurp_color(enum, code))
        when '59'
          set(:underline_color, code)
        when '60', '61'
          set(:ideogram_underline, code)
        when '62', '63'
          set(:ideogram_overline, code)
        when '64'
          set(:ideogram_stress, code)
        when '65'
          set(:ideogram_stress, :ideogram_overline, :ideogram_underline, code)
        when '73', '74', '75'
          set(:vertical_position, code)
        else
          unknown(code)
        end
      end
    rescue StopIteration
      # go until the end
    end
  end
end
