# frozen_string_literal: true

module BwRex
  module Core
    module DSL
      class SearchProxy < BaseProxy
        def initialize(name, options = {})
          super
          @order_by = {}
        end

        def criteria(name, options = {})
          register name, @fields[:criteria], options
        end

        def order_by(name, direction = 'ASC')
          @order_by[name] = direction
        end

        def respond(obj)
          super.fetch('rows', [])
        end

        protected

        def args(inst)
          super(inst).tap do |args|
            criterias = @fields[:criteria].map do |field|
              unpack(field, inst) do |name, value, options|
                { name: name.to_s, type: options[:type] || '=', value: value }
              end
            end
            criterias.compact!

            args[:criteria] = criterias unless criterias.empty?
            args[:order_by] = @order_by unless @order_by.empty?
          end
        end
      end
    end
  end
end
