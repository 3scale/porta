# frozen_string_literal: true

module ThinkingSphinx
  class Test

    JOB_CLASSES = [SphinxIndexationWorker, SphinxAccountIndexationWorker].freeze

    class << self

      def real_time_run
        clear
        init
        start index: false

        disabled = Mocha::Mockery.instance.stubba.stubba_methods.any? {|m| m.stubbee == SphinxIndexationWorker && m.method_name == :perform}
        enable_search_jobs! if disabled

        yield
      ensure
        stop
        disable_search_jobs! if disabled
      end

      alias_method :rt_run, :real_time_run

      def indexed_base_models
        ThinkingSphinx::Configuration.instance.index_set_class.new.map(&:model)
      end

      def indexed_models
        indexed_base_models.map { |m| m.descendants.presence || m }.flatten
      end

      def index_for(model)
        ThinkingSphinx::Configuration.instance.index_set_class.new(classes: [model]).first
      end

      def disable_search_jobs!
        ThinkingSphinx::Test::JOB_CLASSES.each do |clazz|
          clazz.any_instance.stubs(:perform)
        end
      end

      def enable_search_jobs!
        ThinkingSphinx::Test::JOB_CLASSES.each do |clazz|
          clazz.any_instance.unstub(:perform)
        end
      end
    end
  end
end

module TestHelpers
  module Sphinx
    def self.included(base)
      base.setup(:disable_search_jobs!)
    end

    delegate :enable_search_jobs!, to: :'ThinkingSphinx::Test'
    delegate :disable_search_jobs!, to: :'ThinkingSphinx::Test'

    def indexed_models
      ThinkingSphinx::Test.indexed_models
    end

    def indexed_ids(model)
      model.search(middleware: ThinkingSphinx::Middlewares::IDS_ONLY)
    end
  end
end

ActiveSupport::TestCase.include TestHelpers::Sphinx
