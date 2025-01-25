# frozen_string_literal: true

require_relative 'code'

module TTYString
  class CSICode < TTYString::Code
    class << self
      def default_arg(value = nil)
        @default_arg ||= value
        @default_arg || '0'
      end

      private

      def match?(parser)
        parser.scan(re)
      end

      def args(parser)
        a = parser.matched.slice(2..-2).split(';')
        a = a.slice(0, max_args) unless max_args == -1
        a.map! { |n| n.empty? ? default_arg : n }
        a
      end

      def re
        @re ||= /\e\[#{args_re}#{char}/
      end

      def args_re # rubocop:disable Metrics/MethodLength
        case max_args
          # :nocov:
        when 0 then nil
          # :nocov:
        when 1 then /[0-:<-?]*/
        when -1 then %r{[0-?]*[ -/]*}
        else /(?:(?:[0-:<-?]*)(?:;(?:[0-:<-?]*)){0,#{max_args - 1}})?/
        end
      end

      def max_args
        @max_args ||= begin
          params = instance_method(:action).parameters
          return -1 if params.assoc(:rest)

          params.length
        end
      end
    end

    def integer(value)
      return value.to_i if value.match?(/\A\d+\z/)

      parser.unknown
    end
  end
end

TTYString::Code.descendants.pop
