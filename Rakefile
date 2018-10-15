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
  test_groups = {
    integration: FileList["test/{integration,controllers}/**/*_test.rb"],
    functional: FileList["test/{functional}/**/*_test.rb"],
  }

  test_groups[:unit] = FileList['test/**/*_test.rb'].exclude(*test_groups.values).exclude('test/{performance,remote,support}/**/*')

  test_task = Class.new(Rails::TestTask) do
    def file_list
      if (tests = ENV['TESTS'])
        FileList[tests.strip.split]
      else
        super
      end
    end
  end

  Rake::Task[:run].clear

  test_task.new(:run) do |t|
    desc "Run test files, can use TESTS to pass a list of files"
    task t.name do
      puts
      puts "TESTS='"
      t.file_list.each do |file|
        print "\t", file, "\n"
      end
      puts "'"
    end

    t.verbose = verbose
    t.loader = :direct
  end

  namespace :files do
    test_groups.each do |name,file_list|
      desc "Print test files for #{name} test group"
      task name do
        puts file_list
      end
    end
  end
end

Rake::Task['db:test:load'].enhance do
  Rake::Task['multitenant:test:triggers'].invoke
  Rake::Task['db:test:procedures'].invoke
end
