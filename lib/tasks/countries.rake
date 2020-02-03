# frozen_string_literal: true

namespace :countries do
  desc 'Load countries and currencies'
  task import: :environment do
    ImportCountriesService.call!
  end

  desc 'Disable T5 countries'
  task :disable_t5 => :environment do
    Country.t5_countries.update_all(enabled: false)
  end
end
