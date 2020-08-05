# frozen_string_literal: true

class PaginatingDecorator < Draper::CollectionDecorator
  # support for will_paginate
  delegate :current_page, :total_entries, :total_pages, :per_page, :offset, :limit_value, :model_name, :total_count
end
