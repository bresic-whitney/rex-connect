# frozen_string_literal: true

module RSpec
  module Session
    class TestModel
      include BwRex::Core::Model

      action :success do
        field :id
        field :name
      end
    end

    class TestSession < BwRex::Core::BaseSession
      model TestModel

      attr_accessor :age

      def run
        success
      end
    end
  end
end

RSpec.describe BwRex::Core::BaseSession do
  subject { RSpec::Session::TestSession.new }

  it 'uses fields from the given model' do
    subject.id = 10
    expect(subject.id).to be(10)
  end

  it 'fails with error where fields is not valid' do
    expect { subject.other_field }.to raise_error(NoMethodError)
  end

  it 'executes the method of the given model' do
    model = RSpec::Session::TestModel.new

    allow(RSpec::Session::TestModel).to receive(:new).and_return(model)
    allow(model).to receive(:success).and_return('positive')

    expect(subject.run).to be('positive')
  end

  it 'builds with hash' do
    session = RSpec::Session::TestSession.new(id: 10, age: 40, other_field: true)
    expect(session.id).to be(10)
    expect(session.age).to be(40)
    expect { session.other_field }.to raise_error(NoMethodError)
  end
end
