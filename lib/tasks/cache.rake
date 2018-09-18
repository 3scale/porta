namespace :cache do
  desc 'Flush the cache'
  task flush: :environment do
    Rails.cache.clear
  end

  task clear: :flush
  task clean: :flush
end
