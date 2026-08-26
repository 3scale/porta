require 'thinking_sphinx'
require 'thinking_sphinx/test'

BeforeAll do
  ::ThinkingSphinx::Test.disable_search_jobs!
end

Before '@search' do
  ActiveJob::Base.queue_adapter = :inline

  ::ThinkingSphinx::Test.stop
  ::ThinkingSphinx::Test.clear
  ::ThinkingSphinx::Test.init
  $searchd_autostop_installed ||= ::ThinkingSphinx::Test.autostop
  ::ThinkingSphinx::Test.wait_start

  ::ThinkingSphinx::Test.enable_search_jobs!
end

After '@search' do
  ::ThinkingSphinx::Test.disable_search_jobs!
  ::ThinkingSphinx::Test.stop

  ActiveJob::Base.queue_adapter = Rails.configuration.active_job.queue_adapter
end
