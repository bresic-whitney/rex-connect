# frozen_string_literal: true

module BwRex
  module Core
    module DSL
      class Node
        attr_reader :fields

        def initialize(options = {})
          @options = options
          @fields = {}
        end

        def field(name, options = {})
          @fields[name] = options
        end
      end
    end
  end
end
