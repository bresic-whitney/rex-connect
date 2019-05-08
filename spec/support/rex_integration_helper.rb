# frozen_string_literal: true

module RexIntegrationHelper
  LISTINGS_FIELDS = YAML.safe_load(File.read(File.join(File.dirname(__FILE__), '../fixtures/listing_fields.yml'))).freeze
  PROFILES = YAML.safe_load(File.read(File.join(File.dirname(__FILE__), '../fixtures/profiles.yml'))).freeze
  PHOTO = 'https://res.cloudinary.com/hlha8aud5/image/upload/c_fill,h_1558,w_2336/c_limit,dpr_auto,f_auto,w_auto/v1551395729/bw_photo_1_2116029.jpg'
  FLOORPLAN = 'https://res.cloudinary.com/hlha8aud5/image/upload/c_pad,h_1558,w_2336/c_limit,dpr_1.0,f_auto,w_1168/v1551416363/bw_floorplan_1_7210835.jpg'
  SUBURBS = %w[ALEXANDRIA ANNANDALE BARANGAROO HAYMARKET SYDNEY ULTIMO].freeze
  FACILITIES = (1...5).to_a.freeze
  SUBCATEGORY = 'House'

  def listing_profiles
    PROFILES.keys
  end

  def listing_fields(category = 'base')
    LISTINGS_FIELDS[category]
  end

  def find_or_create_listing(label = :bw_residential, opts = {})
    find_listing(label) || create_listing(label, opts)
  end

  def find_listing(label)
    listings = BwRex::Listings.find_by_alternative_id(inbound_unique_id: label)
    listings.first&.fetch('_id', nil)
  end

  # WARNING!!! NEVER CREATE MORE THAN ONE LISTING WITH THE SAME 'inbound_unique_id'
  def create_listing(label, opts = {})
    options = default_options.merge(PROFILES.fetch(label.to_s, {})).merge(opts)

    listing = BwRex::Listings.new(options)
    listing.price_advertise_as = "$ #{options[:price]}"
    listing.inbound_unique_id = label

    parameters = options.merge(address).merge(listing: listing)
    session = BwRex::PublishNewListingSession.new(parameters)
    session.listing_subcategory(SUBCATEGORY)
    session.listing_advert(body: "Summary\r\nHighlights\n*First item\n*Second item")
    session.listing_image(PHOTO)

    session.run
  end

  def address
    {
      street_number: rand(1...999),
      street_name: 'George Street',
      suburb: SUBURBS.sample.capitalize,
      state: 'NSW',
      postcode: '2000',
      bedrooms: FACILITIES.sample,
      bathrooms: FACILITIES.sample,
      garages: FACILITIES.sample
    }
  end

  def default_options
    {
      listing_category: 'residential_sale',
      agent_1: BwRex::Users.find(email: 'jzreika@dius.com.au'),
      agent_2: BwRex::Users.find(email: 'will@bresicwhitney.com.au'),
      price: 1_000_000
    }
  end
end

RSpec.configure do |config|
  config.include RexIntegrationHelper, type: :feature
end
