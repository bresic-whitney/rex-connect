# Bw:Rex

BresicWhitney web gem for REX integration

## Installation in application

Add this line to your application's Gemfile:

```
gem 'bw-rex', git: 'https://github.com/bresic_whitney/rex-connect', tag: '0.0.1'
```

And then execute:

    $ bundle


## Local setup

### Install ruby

Recommend you install rbenv to manage ruby versions

Update rbenv versions if required

```
$ rbenv install --list
$ brew update
$ brew upgrade ruby-build
```

Install ruby version as specified in .ruby_version

```
$ rbenv install 2.6.3
```

Install bundler

```
$ gem install bundler
```

```
$ bundle install
```

### Run tests without integration

```
$ bundle exec rspec --tag=~integration
```

### Run tests with integration

Integration tests run against rex demo environment.  You'll need rex username and password

```
$ REX_USERNAME=<rex username> REX_PASSWORD=<rex password> rspec
```

## Code quality checks

Rspecs (including integration) code quality checks including code coverage are run under the default rake task

```
$ USERNAME=<rex username> PASSWORD=<rex password> rake
```

* [Rubocop](https://github.com/bbatsov/rubocop) for coding guidelines
* [Rails best practices](https://github.com/railsbp/rails_best_practices) for coding guidelines
* [Simple cov](https://github.com/colszowka/simplecov) for code coverage

### Rubocop

Enforce good coding standards

To see any violations:
```
rubocop
```

To auto correct any violations
```
rubocop -a
```

## Git tags

Create a new git tag with new version when consumer needs new version of this gem to reference in external gemfile

Use format '0.0.1' as a guide

```
$ git tag <your version eg. 0.0.1>
$ git push --tags
```

Always update version.rb with the same version


# Query Model Interface

A new version of the gem implements an easier and more standard approach.

## Configuration

In the Rails app, add to the file config/inizializers/bw_rex.rb

```ruby
BwRex.configure do |config|
  config.logger = Rails.logger
  config.endpoint = ENV['REX_ENDPOINT']
  config.environment_id = ENV['REX_ENVIRONMENT_ID']
  config.email = ENV['REX_USERNAME']
  config.password = ENV['REX_PASSWORD']
  config.multi_user = false
  config.sync_period_in_days = ENV['REX_SYNC_PERIOD_DAYS'].to_i
  config.custom_type_id = ENV['REX_CUSTOM_LISTING_TYPE_ID']
  config.custom_view_mode_id = ENV['REX_CUSTOM_VIEW_MODE_ID']
  config.custom_admin_email_id = ENV['REX_CUSTOM_ADMIN_EMAIL_ID']
end
```

Alternative configuration for multi user environment is

```ruby
BwRex.configure do |config|
  config.logger = Rails.logger
  config.endpoint = ENV['REX_ENDPOINT']
  config.environment_id = ENV['REX_ENVIRONMENT_ID']
  config.multi_user = true
end
```

To make sure that the rex server is reachable and active:

```ruby
BresicWhitneyWeb::Application.config.after_initialize do
  BwRex.welcome unless Rails.env.test?
end
```

## Sample code

It is possible to use a Model for a simple query:

```ruby
# ./lib/bw_rex/models/published_listings.rb

BwRex::PublishedListings.listings_for_ids(ids: [1265, 9875])
```

Or a Session for a more complex task

```ruby
# ./lib/bw_rex/sessions/setup_contact_session.rb

session = BwRex::SetupContactSession.new(email: 'test@email.com',...)
session.run
```

Models (and in part Sessions) are pretty flexible in terms of values attribution.

```ruby

contact = BwRex::Contacts.new
contact.email = 'test@example.com'

# can be

contact = BwRex::Contacts.new(email: 'test@example.com')

# or

contact = BwRex::Contacts.new
contact.attributes = { email: 'test@example.com' }
```

The functions can be also invoked at a class level or at the instance level

```ruby
contact = BwRex::Contacts.new(email: 'test@example.com')
contact.search_ids_by_email

# or

BwRex::Contacts.search_ids_by_email(email: 'test@example.com')
```

To display the query produced by each functions:

```ruby
contact = BwRex::Contacts.new(email: 'test@example.com')
contact.query(:search_ids_by_email)

# or

BwRex::Contacts.query(:search_ids_by_email, email: 'test@example.com')

# {
#   method: 'Contacts::search',
#   args: {
#     result_format: 'ids',
#     criteria: [{
#       name: 'contact.email_address',
#       type: '=',
#       value: 'some@email.com'
#     }]
#   }
# }
```

# New models

Helps developers to write Rex Functions, providing an intuitive Domain Specific Language

## Models

Include the core model `include BwRex::Core::Model` to enable the interface.

If the name of the model is different the Rex Entity, it is possible to use an alias, otherwise for the query it will be used the name of the class

```Ruby
module BwRex
  class Users
    include BwRex::Core::Model

    as 'AccountUsers'
    ...
  end
end
```

### Actions

Generally the name of the action is the name of the rex function.

```Ruby
module BwRex
  class AccountUsers
    include BwRex::Core::Model

    action :read do
      field :id
    end
  end
end

BwRex::AccountUsers.read(id: 520)

# would send to Rex the query
#=> {
#=>   method: 'AccountUsers::read',
#=>   args: {
#=>     id: 520
#=>   }
#=> }

```

However it is possible to use an alias: `as: 'someOtherRexFunction'`

There are a few predefined actions that would change slightly the query and the response:
* `:create`: Wraps the fields inside a `data` node and allow the option `return_id: true`
* `:update`: Wraps the fields inside a `data` node and allow the option `return_id: true`
* `:search`: Enables the methods `criteria` and `order_by` (in addition to `field`). Returns an Array
* `:find`: Enables `criteria` and `order_by` (in addition to `field`). Returns an Object

### Fields

Every fields configured within an action, can be later on accessed in the instance (write or read mode) unless the option `value` is used.

If the model has too many actions and fields, it is possible to use the method `attributes` for a more declarative way.

```Ruby
module BwRex
  class AccountUsers
    include BwRex::Core::Model

    attributes: :id, :name, :age

    action :read do
      field :id, presence: true
      field :type, as: '_type', value: 'Contact'
      field :name, default: 'Anonymous'
      field :age, range: true
    end
  end
end
```

Available options are:
* as: Fields can also have alias
* presence: if true and the value generated runtime is nil or empty, an error will be thrown
* value: static value
* default: static value if the value generated runtime is nil or empty
* range: it will expect the value to be and array of two elements [min, max]. It also adds two more accessors (e.g `age_min`, `age_max`)  

It is possible to group fields in two specific nodes: `related` and `extra_options`.

### Rendering (map)

By default the action returns the plain json resulted from the rex server.
It is possible to transform the result with a local block.

```Ruby

BwRex::AccountUsers.read(id: '1') do |json|
  { id: json['_id'], name: json['full_name'] }
end

# => { id: '1', name: 'Jason Smith' }
```

In case of array the block will be reused.

It is also available the mixin `map`

```Ruby
module BwRex
  class AccountUsers
    include BwRex::Core::Model

    map do
      field :id, as: '_id'
      field :name, as: 'details.full_name' # nested
      field :pictures, as: 'pictures.url' # array of string
      field :documents, as: 'documents', use: BwRex::Documents # array of Models
    end
  end
end
```

Available options are:
* as: Fields can also have alias
* use: Class of the model to use to parse the partial

## TODO

Implement performance test
