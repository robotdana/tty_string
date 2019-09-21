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
        parser.matched.slice(2..-2).split(';')
          .map { |n| n.empty? ? default_arg : n.to_i }
      end

      def re
        @re ||= /\e\[#{args_re}#{char}/
      end

      def args_re
        case max_args
        when 1 then /#{arg_re}?/
        when nil then /(#{arg_re}?(;#{arg_re})*)?/
        else /(#{arg_re}?(;#{arg_re}){0,#{max_args - 1}})?/
        end
      end

      def arg_re
        /\d*/
      end

      def max_args
        @max_args ||= begin
          params = instance_method(:action).parameters
          return if params.assoc(:rest)

          params.length
        end
      end
    end
  end
end

TTYString::Code.descendants.pop
