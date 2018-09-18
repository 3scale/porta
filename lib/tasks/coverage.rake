task :coverage do
  require 'simplecov'
  SimpleCov::ResultMerger.merged_result.format!
end
