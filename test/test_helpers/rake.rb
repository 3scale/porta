require 'rake'

module TestHelpers
  module Rake
    private

    def execute_rake_task(file,task,*args)
      rake = ::Rake::Application.new
      ::Rake.application = rake
      ::Rake::Task.define_task(:environment)
      load "#{Rails.root}/lib/tasks/#{file}"
      rake[task].invoke(*args)
    end
  end
end

ActiveSupport::TestCase.send(:include, TestHelpers::Rake)