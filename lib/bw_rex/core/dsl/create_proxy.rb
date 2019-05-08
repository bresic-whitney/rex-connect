# frozen_string_literal: true

module BwRex
  module Core
    module DSL
      class CreateProxy < BaseProxy
        def args(inst)
          { data: super(inst) }.tap do |me|
            me[:return_id] = true if return_id?
          end
        end

        def return_id?
          @options[:return_id] == true
        end
      end
    end
  end
end
