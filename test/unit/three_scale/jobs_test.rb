require 'test_helper'

class ThreeScale::JobsTest < ActiveSupport::TestCase

  include ThreeScale::Jobs

  ALL = MONTH + DAILY + BILLING + HOUR

  ALL.each do |job|
    name = job.tr(':.', '_')
    module_eval <<-RUBY, __FILE__, __LINE__ + 1
      def test_#{name}
        FactoryBot.create(:provider_account)
        #{job}
      end
    RUBY
  end

  def test_whenever
    assert system('whenever > /dev/null'), 'whenever command failed to generate crontab'
  end
end
