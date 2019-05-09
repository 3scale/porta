# frozen_string_literal: true

require 'test_helper'

class Features::SegmentDeletionConfigTest < ActiveSupport::TestCase
  def setup
    @valid_config = {'enabled' => true, 'email' => 'email@example.com', 'password' => 'example-password', 'uri' => 'https://gdpr.example.com/graphql', workspace: 'workspace'}
  end

  attr_reader :valid_config

  test 'loads and fetches all the values' do
    valid_config.each { |key, value| assert_equal value, segment_deletion_config.config.public_send(key) }
    assert segment_deletion_config.enabled?
  end

  test 'it is not enabled if the config is not provided or if enabled is false' do
    refute segment_deletion_config('').enabled?
    refute segment_deletion_config(valid_config.merge('enabled' => false)).enabled?
  end

  private

  def segment_deletion_config(config = valid_config)
    Features::SegmentDeletionConfig.new(config)
  end
end
