# frozen_string_literal: true

require_relative 'code'

class TTYString
  class CSICode < TTYString::Code
    class << self
      def default_arg(value = nil)
        @default_arg ||= value
        @default_arg || 1
      end

      private

      def match?(parser)
        parser.scan(re)
      end

      def args(parser)
        a = parser.matched.slice(2..-2).split(';')
        a = a.slice(0, max_args) unless max_args == -1
        a.map! { |n| n.empty? ? default_arg : n.to_i }
        a
      end

      def re
        @re ||= /\e\[#{args_re}#{char}/
      end

      def args_re # rubocop:disable Metrics/MethodLength
        case max_args
        when 0 then nil
        when 1 then /#{arg_re}?/
        when -1 then /(#{arg_re}?(;#{arg_re})*)?/
        else /(#{arg_re}?(;#{arg_re}){0,#{max_args - 1}})?/
        end
      end

      def arg_re
        /\d*/
      end

      def max_args
        @max_args ||= begin
          params = instance_method(:action).parameters
          return -1 if params.assoc(:rest)

          params.length
        end
      end
    end
  end
end

TTYString::Code.descendants.pop
