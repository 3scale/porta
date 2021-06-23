require 'test_helper'

class ThreeScale::JobsTest < ActiveSupport::TestCase

  include ThreeScale::Jobs

  ALL = MONTH + DAILY + BILLING + HOUR

  ALL.each do |job|
    define_method("test_#{job.name}") do
      FactoryBot.create(:provider_account)
      job.run
    end
  end
end
