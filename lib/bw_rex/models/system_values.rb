# frozen_string_literal: true

module BwRex
  class SystemValues
    include BwRex::Core::Model

    action :list, as: 'getCategoryValues' do
      field :list_name, presence: true
    end

    action :suburbs, as: 'autocompleteCategoryValues' do
      field :list_name, value: 'suburbs'
      field :search_string, presence: true
    end

    def self.suburb(name)
      new(search_string: name).suburbs.find { |s| s['suburb_or_town'] == name }
    end

    def self.listing_subcat(category, subcategory)
      list_name = "listing_subcat_#{category}"
      new(list_name: list_name).list.find { |s| s['text'] == subcategory }
    end
  end
end
