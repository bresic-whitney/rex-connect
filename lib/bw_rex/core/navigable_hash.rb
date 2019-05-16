# frozen_string_literal: true

module BwRex
  module Core
    module NavigableHashUtils
      def dig_and_collect(*keys)
        keys = keys.dup

        next_key = keys.shift
        return unless key? next_key

        next_val = self[next_key]

        return next_val if keys.empty?
        return NavigableHash[next_val].dig_and_collect(*keys) if next_val.is_a? Hash
        return unless next_val.is_a? Array

        Array(next_val).each_with_object([]) do |v, result|
          inner = NavigableHash[v].dig_and_collect(*keys)
          result.concat Array(inner)
        end
      end
    end

    class NavigableHash < Hash
      include NavigableHashUtils
    end
  end
end
