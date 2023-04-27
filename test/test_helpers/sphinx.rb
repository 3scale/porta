# frozen_string_literal: true

module ThinkingSphinx
  class Test

    class << self

      def real_time_run
        init
        start index: false
        yield
      ensure
        stop
      end
      alias_method :rt_run, :real_time_run

      def disable_real_time_callbacks!
        original_settings = ThinkingSphinx::Configuration.instance.settings
        new_settings = original_settings.dup.merge({"real_time_callbacks" => false})
        ThinkingSphinx::Configuration.any_instance.stubs(:settings).returns(new_settings)
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
    end
  end
end
