# workaround unresolved issue with manticore total_pages
# fixes SearchPresentersTest#test_pagination
# see https://github.com/pat/thinking-sphinx/pull/1213
ThinkingSphinx::Masks::PaginationMask.prepend(Module.new do
  def total_pages
    return 0 unless search.meta['total_found']

    # 1000 is the default server max_matches value. We should stay at or below the server setting here.
    @total_pages ||= ([total_entries, 1000].min / search.per_page.to_f).ceil
  end
end)
