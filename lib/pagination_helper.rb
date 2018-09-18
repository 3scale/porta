module PaginationHelper

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods

    def pagination_attrs(collection)
      if show_pagination?(collection)
        { :per_page => collection.per_page, :total_entries => collection.total_entries,
          :total_pages => collection.total_pages, :current_page => collection.current_page }
      else
        {}
      end
    end

    def show_pagination?(collection)
      collection.respond_to?(:per_page) && collection.respond_to?(:total_entries) &&
        collection.per_page < collection.total_entries
    end

  end
end
