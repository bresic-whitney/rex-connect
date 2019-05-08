# frozen_string_literal: true

module BwRex
  class CustomFields
    include BwRex::Core::Model

    action :list, as: 'describeSearchFields' do
      field :service_name
    end

    action :set, as: 'setFieldValues' do
      field :service_name, default: 'Listings'
      field :id, as: :service_object_id, presence: true
      field :value_map, default: []
    end

    action :get, as: 'getValuesKeyedByFieldId' do
      field :service_name, default: 'Listings'
      field :id, as: :service_object_id, presence: true
    end
  end
end
