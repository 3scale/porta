# frozen_string_literal: true

require 'sidekiq/testing'
require 'sidekiq/lock/testing/inline'

module TestHelpers
  module Sidekiq
    def self.included(base)
      base.setup do
        ::Sidekiq::Worker.clear_all
      end

      base.teardown do
        ::Sidekiq::Worker.clear_all
      end
    end
  end
end

ActiveSupport::TestCase.send(:include, TestHelpers::Sidekiq)
