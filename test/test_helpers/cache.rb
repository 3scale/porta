class ActiveSupport::TestCase
  private

  def stub_cache
    Rails.cache.stubs(:read)
    Rails.cache.stubs(:write).returns(true)
    Rails.cache.stubs(:increment)
    Rails.cache.stubs(:decrement)
  end

  def stub_cache_access_to_non_cinstance_data
    match = regexp_matches(/^cinstance_data\//)

    Rails.cache.stubs(:read).with(Not(match), any_parameters)
    Rails.cache.stubs(:write).with(Not(match), any_parameters).returns(true)
  end

  def stub_cache_access_to_non_transaction_data
    match = regexp_matches(/^transactions\//)

    Rails.cache.stubs(:read).with(Not(match), any_parameters)
    Rails.cache.stubs(:write).with(Not(match), any_parameters).returns(true)
  end

  def stub_cache_access_to_non_usage_data
    match = regexp_matches(/^usage_data\//)
    Rails.cache.stubs(:read).with(Not(match), any_parameters)
    Rails.cache.stubs(:write).with(Not(match), any_parameters).returns(true)
  end
end
