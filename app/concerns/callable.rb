# frozen_string_literal: true

module Callable
  extend ActiveSupport::Concern

  included do
    private_class_method :new
  end

  class_methods do
    def call(*args)
      new(*args).call
    end
  end
end
