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

    end
  end
end
