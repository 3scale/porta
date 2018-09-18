# TODO: cleanup require statements
require File.expand_path(File.dirname(__FILE__) + '/sphinx')

require 'action_mailer'
ActionMailer::Base.delivery_method = :test

require 'mail'
require 'email_spec'
require 'email_spec/cucumber'
require "#{File.dirname(__FILE__)}/timecop_helpers"
require "#{File.dirname(__FILE__)}/plan_helpers"

World(TimecopHelpers)
World(PlanHelpers)
World(DummyAttachments)

require File.expand_path(File.dirname(__FILE__) + '/helpers/js_helpers')
require File.expand_path(File.dirname(__FILE__) + '/helpers/messages_helpers')
require File.expand_path(File.dirname(__FILE__) + '/helpers/backend_helpers')
require File.expand_path(File.dirname(__FILE__) + '/helpers/apps_keys_helpers')
require File.expand_path(File.dirname(__FILE__) + '/helpers/site_account_support')


World(JsHelpers)
World(MessagesHelpers)
World(BackendHelpers)
World(AppsKeysHelpers)
World(SiteAccount)
World(ProviderNaming)

require 'action_controller'

# fixes loading files from fixtures
ActionDispatch::Integration::Session.class_eval do
  def self.fixture_path
    ActionController::TestCase.fixture_path
  end
end
