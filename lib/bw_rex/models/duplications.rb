# frozen_string_literal: true

module BwRex
  class Duplications
    include BwRex::Core::Model

    as 'Dedupe'

    action :combine, as: 'combineRecords' do
      field :service_name, presence: true, default: 'Contacts'
      field :winning_id, presence: true
      field :losing_ids, presence: true
    end
  end
end
