require 'test_helper'

class Onboarding::ApiFormTest < ActiveSupport::TestCase

  def test_api_backend
    api = Onboarding::ApiForm.new(service: FactoryGirl.build(:service),
                                  proxy:   FactoryGirl.build(:proxy))

    assert_equal nil, api.backend


    api = Onboarding::ApiForm.new(service: FactoryGirl.build(:service),
                                  proxy:   FactoryGirl.build(:proxy,
                                                             created_at: 1.week.ago,
                                                             api_backend: 'http://example.com'))

    assert_equal URI('http://example.com'), api.backend
  end

  def test_name
    api = Onboarding::ApiForm.new(service: FactoryGirl.build(:service),
                                  proxy:   FactoryGirl.build(:proxy))

    assert_equal nil, api.name


    api = Onboarding::ApiForm.new(service: FactoryGirl.build(:service,
                                                             name: 'Some Name',
                                                             created_at: 1.week.ago),
                                  proxy:   FactoryGirl.build(:proxy))

    assert_equal 'Some Name', api.name
  end

  def test_invalid_backend
    api = Onboarding::ApiForm.new(service: FactoryGirl.build(:service),
                                  proxy:   FactoryGirl.build(:proxy))
    api.name = 'foo'

    assert api.save, api.errors

    api.backend = backend = '8.8.8.8:3000'
    assert_equal backend, api.backend

    refute api.save
  end

  def test_save
    api = Onboarding::ApiForm.new(service: FactoryGirl.build(:service),
                                  proxy:   FactoryGirl.build(:proxy))


    assert api.validate(backend: 'invalid', name: 'foo')
    assert api.errors.empty?

    refute api.save

    assert api.errors.present?
  end
end
