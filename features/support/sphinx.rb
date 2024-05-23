require 'thinking_sphinx'
require 'thinking_sphinx/test'

BeforeAll do
  ::ThinkingSphinx::Test.disable_search_jobs!
end

Before '@search' do
  Sidekiq::Job.clear_all
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
end
