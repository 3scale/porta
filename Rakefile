require File.expand_path('../config/application', __FILE__)

# Workaround for https://github.com/ruby/rake/issues/116
# until we upgrade rspec
Rake::TaskManager.module_eval do
  alias_method :last_comment, :last_description
end

System::Application.load_tasks

# load parallel_tests rake tasks
begin; require 'parallel_tests/tasks'; rescue LoadError; end


begin
  require 'thinking_sphinx/deltas/datetime_delta/tasks'
rescue LoadError
end

namespace :test do
  Rake::TestTask.new(:specs) do |t|
    t.libs << "test"
    t.pattern = 'test/**/*_spec.rb'
  end

  Rake::TestTask.new(:proxy) do |t|
    t.libs << 'test'
    t.pattern = 'test/proxy/**/*_test.rb'
  end
end

Rake::Task['db:test:load'].enhance do
  Rake::Task['multitenant:test:triggers'].invoke
end
