# frozen_string_literal: true

module TestHelpers
  module Env
    private

    def set_env(var_values)
      original = ENV.to_hash
      ENV.update var_values
      yield
    ensure
      ENV.replace original
    end
  end
end

ActiveSupport::TestCase.send(:include, TestHelpers::Env)
