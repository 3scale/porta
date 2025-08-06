# frozen_string_literal: true

require 'mail'
require 'email_spec'
require 'email_spec/cucumber'

ActionMailer::Base.delivery_method = :test

# fixes loading files from fixtures
ActionDispatch::Integration::Session.class_eval do
  def self.fixture_paths
    ActionController::TestCase.fixture_paths
  end
end
