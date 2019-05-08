# frozen_string_literal: true

module BwRex
  module Core
    module DSL
      class FindProxy < SearchProxy
        def initialize(_name, options = {})
          super :search, options
          field :limit, value: 1
          field :offset, value: 0
        end

        def respond(obj)
          super.first # || raise('Entity not found')
        end
      end
    end
  end
end
