require 'thinking_sphinx'
require 'thinking_sphinx/test'

Before('@search') do
  raise ::Cucumber::Core::Test::Result::Skipped, 'Sphinx does not support OracleDB' if System::Database.oracle?
  ::ThinkingSphinx::Test.init
  ::ThinkingSphinx::Test.stop
  output = ::ThinkingSphinx::Test.start_with_autostop
  assert ::ThinkingSphinx::Test.config.controller.running?, "thinking sphinx should be running: #{output}"
end

AfterStep '@search' do
  ::ThinkingSphinx::Test.index
end

After '@search' do
  ::ThinkingSphinx::Test.stop
end
