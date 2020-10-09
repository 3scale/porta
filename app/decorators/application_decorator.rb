# frozen_string_literal: true

class ApplicationDecorator < Draper::Decorator
  delegate_all

  self.include_root_in_json = true

  def api_selector_api_link
    raise NoMethodError, __method__
  end

  def self.collection_decorator_class
    PaginatingDecorator
  end
end
