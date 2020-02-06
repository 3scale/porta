module TestHelpers
  module ProxyConfigAffectingChangesHelpers
    def with_proxy_config_affecting_changes_tracker
      Thread.new do
        tracker = ProxyConfigAffectingChanges::Tracker.new
        Thread.current[ProxyConfigAffectingChanges::TRACKER_NAME] = tracker
        yield(tracker)
      end.join
    end
  end
end

ActiveSupport::TestCase.class_eval do
  include TestHelpers::ProxyConfigAffectingChangesHelpers
end
