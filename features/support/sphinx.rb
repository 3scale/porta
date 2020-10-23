# frozen_string_literal: true

require 'thinking_sphinx'
require 'thinking_sphinx/test'

Before('@search') do
  Sidekiq::Worker.clear_all
  raise ::Cucumber::Core::Test::Result::Skipped, 'Sphinx does not support OracleDB' if System::Database.oracle?
  ::ThinkingSphinx::Test.init
  ::ThinkingSphinx::Test.stop
  ::ThinkingSphinx::Test.autostop
  output = ::ThinkingSphinx::Test.start index: false
  assert ::ThinkingSphinx::Test.config.controller.running?, "thinking sphinx should be running: #{output}"
end

After '@search' do
  ::ThinkingSphinx::Test.stop
end
