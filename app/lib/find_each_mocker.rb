class FindEachMocker
  delegate :total_entries, :current_page, :total_pages, to: :collection

  def initialize(collection, per_page: 1000, page: 1)
    @collection = collection.paginate(per_page: per_page, page: page)
  end

  def find_in_batches
    return enum_for(__method__) { total_pages } unless block_given?

    current_page.upto(total_pages) do |page|
      yield collection.page(page)
    end
  end

  def find_each(&block)
    return enum_for(__method__) { total_entries } unless block_given?

    find_in_batches do |records|
      records.each(&block)
    end
  end

  protected

  attr_reader :collection
end
