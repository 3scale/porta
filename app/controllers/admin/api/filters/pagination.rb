module Admin::Api::Filters::Pagination
  extend ActiveSupport::Concern

  class PaginationError < ArgumentError; end

  class InvalidPageError < PaginationError; end
  class InvalidMaxPageError < PaginationError; end

  included do
    # is there a reason why we wan't to play smartypants gods and set
    # page to 1 if user passed -1 ? or can we throw error and chill out?
    # enable this when you find answer for the ultimate question
    #
    # rescue_from PaginationError do |exception|
    #   respond_with(exception)
    # end

    class_attribute :page_range, :default_page
    class_attribute :per_page_range, :default_per_page

    class_attribute :pagination_enabled

    self.page_range = 1..Float::INFINITY
    self.default_page = 1

    self.per_page_range = 1..500
    self.default_per_page = 500
  end

  module ClassMethods
    def paginate(options = {})
      before_action :enable_pagination, options
    end
  end

  def paginated?
    !!@_paginated
  end

  protected

  def enable_pagination
    @_paginated = true
  end

  def pagination_params
    { page: current_page, per_page: per_page }
  end

  def current_page
    @page ||= begin
      page = params.fetch(:page){ page_range }.to_i
      page_range.cover?(page) ? page : default_page
    rescue
      # raise InvalidPageError
      default_page
    end
  end

  def per_page
    @per_page ||= begin
      per_page = params.fetch(:per_page){ default_per_page }.to_i
      per_page_range.cover?(per_page) ? per_page : default_per_page
    rescue
      # raise InvalidMaxPageError
      default_per_page
    end
  end
end
