# frozen_string_literal: true

require 'set'
require 'bw_rex/core/dsl/utils'
require 'bw_rex/core/dsl/node'
require 'bw_rex/core/dsl/presenter'
require 'bw_rex/core/dsl/base_proxy'
require 'bw_rex/core/dsl/search_proxy'
require 'bw_rex/core/dsl/find_proxy'
require 'bw_rex/core/dsl/create_proxy'
require 'bw_rex/core/dsl/update_proxy'
require 'bw_rex/core/dsl/purge_proxy'

# TODO: fix id compatibility

module BwRex
  module Core
    module DSL
      PROXIES = {
        base: BaseProxy,
        search: SearchProxy,
        find: FindProxy,
        create: CreateProxy,
        update: UpdateProxy,
        purge: PurgeProxy,
        trash: PurgeProxy
      }.freeze

      module InstanceMethods
        def initialize(hash = nil)
          self.attributes = hash if hash.is_a?(Hash)
        end

        def attribute_names
          self.class.instance_variable_get('@attributes').to_a
        end

        def attributes
          attribute_names.each_with_object({}) do |field, hash|
            hash[field] = send(field)
          end
        end

        def attributes=(hash)
          attribute_names.each do |field|
            send("#{field}=", hash.fetch(field, nil))
          end
        end
      end

      module ClassMethods
        def self.extended(base)
          base.instance_variable_set('@attributes', Set.new)
          base.instance_variable_set('@name', base.name.split('::').last)
          base.instance_variable_set('@presenter', Presenter.new(base))
          base.instance_variable_set('@actions', {})

          base.send(:define_method, :query) do |name|
            actions = self.class.instance_variable_get('@actions')
            raise "Action '#{name}' not configured." unless actions[name.to_sym]

            actions[name.to_sym].query(self)
          end

          base.send(:define_singleton_method, :query) do |name, attrs = {}|
            new(attrs).send(:query, name)
          end
        end

        def as(name)
          @name = name
        end

        def attributes(*list)
          merge_attributes(list)
        end

        # TODO: Add debug option

        def action(name, options = {}, &block)
          action = proxy_instance(name, self, options)
          action.instance_eval(&block) if block_given?
          @actions[name] = action

          merge_attributes(action.attributes)
          define_singleton_method(name) { |attr = {}, &transformer| new(attr).send(name, &transformer) }
          define_method(name) { |&transformer| self.class.execute(action, self, &transformer) }
        end

        def map(options = {}, &block)
          @presenter.options = options
          @presenter.instance_eval(&block) if block_given?
          merge_attributes(@presenter.attributes)
        end

        def execute(action, instance, &transformer)
          query = action.query(instance)
          response = instance.request(query)
          output = action.respond(response)

          if action.debug?
            StringIO.new.tap do |io|
              io.puts '========================='
              io.puts JSON.pretty_generate(query)
              io.puts '-------------------------'
              io.puts JSON.pretty_generate(output)
              io.puts '========================='
              STDOUT.print(io.string)
            end
          end

          render(output, &transformer)
        end

        def render(response, &transformer)
          block = transformer || @presenter.method(:render)
          response.is_a?(Array) ? response.map(&block) : block.call(response)
        end

        private

        def proxy_instance(name, host, options)
          options[:model] ||= @name || host.name.split('::').last
          proxy_class(options[:as] || name).new(name, options)
        end

        def proxy_class(key = :nil)
          PROXIES.fetch(key.to_sym, BaseProxy)
        end

        def merge_attributes(atts = [])
          to_add = atts.uniq.compact.map(&:to_sym) - @attributes.to_a
          to_add.each { |a| attr_accessor(a) }
          @attributes.merge(to_add)
        end
      end
    end
  end
end
