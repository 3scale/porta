require 'performance_helper'

class Workers::DeleteObjectHierarchyTest < ActionDispatch::PerformanceTest
  self.profile_options = { metrics: [:wall_time] }

  def setup
    @provider = FactoryBot.create(:provider_account)
    @provider.schedule_for_deletion!

    SystemOperation::DEFAULTS.keys.each do |name|
      @provider.mail_dispatch_rules.create!(system_operation: SystemOperation.for(name))
    end
  end

  def test_run
    DeleteObjectHierarchyWorker.perform_now(@provider)
  end
end
