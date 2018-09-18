require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class Backend::RandomDataGeneratorTest < ActiveSupport::TestCase
  disable_transactional_fixtures!

  test 'generate' do
    provider = Factory :provider_account
    cinstance = provider.bought_cinstances.first
    stats = Stats::Client.new(cinstance)

    silence_stream($stdout) do
      Backend::RandomDataGenerator.generate(cinstance_id: cinstance.id,
                                            since: 1.minute.ago,
                                            until: Time.zone.now,
                                            min: 1,
                                            frequency: 0.01)
    end

    total_hits = stats.total_hits(period: :eternity)
    assert_operator total_hits, :>, 0
  end
end
