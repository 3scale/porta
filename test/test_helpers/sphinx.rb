# frozen_string_literal: true

module ThinkingSphinx
  class Test

    JOB_CLASSES = [SphinxIndexationWorker, SphinxAccountIndexationWorker].freeze
    private_constant :JOB_CLASSES

    class << self

      def real_time_run
        clear
        init
        wait_start

        enable_search_jobs!

        yield
      ensure
        stop
        disable_search_jobs!
      end

      alias_method :rt_run, :real_time_run

      def wait_start
        output = start index: false

        5.times { config.controller.running? && break || sleep(1) }
        raise "thinking sphinx should be running:\n#{output.output}" unless ::ThinkingSphinx::Test.config.controller.running?

        10.times do |i|
          Connection.take { _1.execute "SELECT * FROM account_core LIMIT 1" }
          break
        rescue
          raise "thinking sphinx should be accessible:\n#{output.output}" if i >=9
          sleep 1
        end
      end

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
        unless JOB_CLASSES.first.respond_to? :_disable_actual_indexing
          JOB_CLASSES.each do |clazz|
            clazz.class_attribute :_disable_actual_indexing
            clazz.prepend(Module.new do
              def perform(...)
                super unless _disable_actual_indexing
              end
            end)
          end
        end

        JOB_CLASSES.each do |clazz|
          clazz._disable_actual_indexing = true
        end
      end

      def enable_search_jobs!
        return unless JOB_CLASSES.first.respond_to? :_disable_actual_indexing

        JOB_CLASSES.each do |clazz|
          clazz._disable_actual_indexing = false
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
