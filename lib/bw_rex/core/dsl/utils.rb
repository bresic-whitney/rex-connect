# frozen_string_literal: true

module BwRex
  module Core
    module DSL
      module Utils
        def pack(name, options = {})
          FieldManager.pack name, options
        end

        def unpack(field, instance, &block)
          FieldManager.unpack! field, instance, self, &block
        end

        def unpack_all(list, instance)
          list.each_with_object({}) do |field, hash|
            unpack(field, instance) { |name, value, _options| hash[name] = value }
          end
        end

        def merge_lists(incoming, saved, key = :key)
          field = key.to_s
          incoming ||= []
          saved ||= []

          from, to = *[incoming, saved].map { |a| a.map { |s| s[field] }.compact }

          deleted = saved.select { |s| (to - from).include? s[field] }
          added = incoming.select { |s| (from - to).include? s[field] }

          added.concat(deleted.map { |t| { '_id' => t['_id'], '_destroy' => true } }).compact
        end

        class FieldManager
          attr_reader :name, :value, :options

          def self.pack(name, options = {})
            { name: options[:as] || name, value: name, options: options }
          end

          def self.unpack!(field, instance, proxy = nil)
            me = new(field, instance, proxy)
            me.generate
            me.validate

            yield(me.name, me.value, me.options) unless me.nil?
          end

          def generate
            @value = options[:value] || instance_value || options[:default]
          end

          def validate
            raise "'#{@attribute}' cannot be nil on '#{method_name}'" if @options[:presence] == true && nil?
          end

          def nil?
            @value.nil? || empty?
          end

          private

          def initialize(field, instance, proxy = nil)
            @name = field[:name]
            @attribute = field[:value]
            @options = field[:options]
            @instance = instance
            @proxy = proxy
          end

          def instance_value
            return range_value if options[:range] == true

            @instance.public_send(@attribute)
          end

          def range_value
            whole = @instance.public_send(@attribute)
            return %i[min max].zip(whole.take(2)).to_h if whole.is_a?(Array)

            %i[min max].map { |dim| [dim, @instance.public_send("#{@attribute}_#{dim}")] }.to_h
          end

          def method_name
            @proxy.is_a?(BaseProxy) ? @proxy.method_name : 'Anonymous'
          end

          def empty?
            (@value.is_a?(Array) && @value.compact.empty?) || (@value.is_a?(Hash) && @value.values.compact.empty?)
          end
        end
      end
    end
  end
end
