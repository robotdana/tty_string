# frozen_string_literal: true

module TTYString
  class Code
    class << self
      def descendants
        @@descendants
      end

      def inherited(klass)
        @@descendants ||= [] # rubocop:disable Style/ClassVars I want it to be shared between subclasses.
        @@descendants << klass
        @@descendants.uniq!

        super
      end

      def render(parser)
        return unless match?(parser)

        new(parser).action(*args(parser))

        true
      end

      def char(value = nil)
        @char = value if value
        @char ||= name.split('::').last
      end

      private

      def re
        @re ||= /#{char}/.freeze
      end

      def args(_scanner)
        []
      end

      def match?(parser)
        parser.skip(re)
      end
    end

    def initialize(parser)
      @parser = parser
    end

    def action; end

    private

    attr_reader :parser

    def screen
      parser.screen
    end

    def cursor
      parser.cursor
    end
  end
end
