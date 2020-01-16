# frozen_string_literal: true
require 'test_helper'

class Backend::RandomDataGeneratorTest < ActiveSupport::TestCase

  test 'generate' do
    provider = FactoryBot.create :provider_account
    cinstance = provider.bought_cinstances.first
    stats = Stats::Client.new(cinstance)

    Backend::RandomDataGenerator.generate(cinstance_id: cinstance.id,
                                          since: 1.minute.ago,
                                          until: Time.zone.now,
                                          min: 1,
                                          frequency: 0.01)

    total_hits = stats.total_hits(period: :eternity)
    assert_operator total_hits, :>, 0
  end
end
