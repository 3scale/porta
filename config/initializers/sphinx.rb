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

# implement conditionally inserting or deleting from the index
# see https://github.com/pat/thinking-sphinx/pull/1258
ThinkingSphinx::Processor.include(Module.new do
  def stage
    real_time_indices.each do |index|
      found = index.scope.find_by(model.primary_key => id)

      if found
        ThinkingSphinx::RealTime::Transcriber.new(index).copy found
      else
        ThinkingSphinx::Deletion.perform(index, id)
      end
    end
  end
end)
