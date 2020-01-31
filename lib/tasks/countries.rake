# frozen_string_literal: true

require 'open-uri'

class CountriesImportService
  # Ignore these invalid/obsolete countries:
  INVALID_COUNTRY_CODES = %w[CS XK AQ UM] # Serbia and Montenegro, Kosovo (not there yet), Antartica

  # Pass a block that returns a Hash { 'country_code' => { name: 'country name', currency: 'country currency' } }
  def self.call!
    countries = yield

    countries.except(*INVALID_COUNTRY_CODES).each do |code, attributes|
      name, currency = attributes.values_at(*%i[name currency])
      country = Country.find_by(code: code)
      if country
        puts "-- updating #{name} (#{code},#{currency})"
        country.update_attributes!(attributes.merge(updated_at: Time.zone.now))
      else
        puts "-- creating #{name} (#{code},#{currency})"
        Country.create!(attributes.merge(code: code))
      end
    end

    Country.where.not(code: countries.keys).delete_all
  end
end

namespace :countries do
  namespace :import do
    desc 'Import countries from Geonames repository'
    task geonames: :environment do
      CountriesImportService.call! do
        puts '-- downloading...'
        doc = open('http://download.geonames.org/export/dump/countryInfo.txt')
        puts '-- parsing...'
        lines = doc.readlines.reject { |line| line.starts_with?('#') } # comment.
        lines.inject({}) do |countries, line|
          row = line.split("\t")
          countries[row[0]] = { name: row[4], currency: row[10] }
          countries
        end
      end
    end

    desc 'Load countries with tzifo'
    task tzinfo: :environment do
      CountriesImportService.call! do
        TZInfo::Country.all.map { |country| [country.code, { name: country.name }] }.to_h
      end
    end
  end

  task import: 'countries:import:geonames'

  desc 'Disable T5 countries'
  task :disable_t5 => :environment do
    Country.t5_countries.update_all(enabled: false)
  end
end
