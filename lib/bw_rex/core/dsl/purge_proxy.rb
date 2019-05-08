# frozen_string_literal: true

module BwRex
  module Core
    module DSL
      class PurgeProxy < BaseProxy
        def initialize(name, options = {})
          super
          field :id, presence: true
        end
      end
    end
  end
end
