require 'thinking_sphinx'
require 'thinking_sphinx/test'

Before "not @search" do
  ::ThinkingSphinx::Test.disable_search_jobs!
end

Before('@search') do
  Sidekiq::Job.clear_all
  ::ThinkingSphinx::Test.clear
  ::ThinkingSphinx::Test.init
  ::ThinkingSphinx::Test.stop
  ::ThinkingSphinx::Test.autostop
  output = ::ThinkingSphinx::Test.start index: false

  3.times { ::ThinkingSphinx::Test.config.controller.running? && break || sleep(1) }
  raise "thinking sphinx should be running:\n#{output.output}" unless ::ThinkingSphinx::Test.config.controller.running?
end

After '@search' do
  ::ThinkingSphinx::Test.stop
end

After "not @search" do
  ::ThinkingSphinx::Test.enable_search_jobs!
end
