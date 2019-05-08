# frozen_string_literal: true

module BwRex
  module Core
    module DSL
      class UpdateProxy < CreateProxy
        def initialize(name, options = {})
          super
          field :id, as: :_id, presence: true
        end

        def return_id?
          false
        end

        def respond(obj)
          @options[:return_id] == true ? super['_id'] : super
        end
      end
    end
  end
end
