require 'thinking_sphinx'
require 'thinking_sphinx/test'

Before "not @search" do
  ::ThinkingSphinx::Test.disable_search_jobs!
end

Before('@search') do
  Sidekiq::Worker.clear_all
  ::ThinkingSphinx::Test.init
  ::ThinkingSphinx::Test.stop
  ::ThinkingSphinx::Test.autostop
  output = ::ThinkingSphinx::Test.start index: false
  assert ::ThinkingSphinx::Test.config.controller.running?, "thinking sphinx should be running: #{output}"
end

After '@search' do
  ::ThinkingSphinx::Test.stop
end

After "not @search" do
  ::ThinkingSphinx::Test.enable_search_jobs!
end
