# frozen_string_literal: true

require 'open-uri'

class ImportCountriesService
  # Ignore these invalid/obsolete countries:
  INVALID_COUNTRY_CODES = %w[CS XK AQ UM] # Serbia and Montenegro, Kosovo (not there yet), Antartica

  class CountryData
    def self.from_hash(hash)
      values = hash.with_indifferent_access.values_at(*%i[code name currency])
      new(*values)
    end

    def initialize(code, name, currency)
      @code = code
      @name = name
      @currency = currency
    end

    attr_reader :code, :name, :currency

    def to_h
      { code: code, name: name, currency: currency }
    end

    alias attributes to_h

    def attributes_for_update
      attributes.slice(:name, :currency).merge(updated_at: Time.zone.now)
    end

    def valid?
      !INVALID_COUNTRY_CODES.include?(code)
    end

    def to_s
      "#{name} (#{code},#{currency})"
    end
  end

  class GeonamesLoader
    def self.load_countries
      doc = URI.open('http://download.geonames.org/export/dump/countryInfo.txt')
      lines = doc.readlines.reject { |line| line.starts_with?('#') } # comment.
      lines.map do |line|
        row = line.split("\t")
        CountryData.new(row[0], row[4], row[10])
      end
    end
  end

  def self.call!
    new.call!
  end

  def initialize
    @countries = load_countries
  end

  attr_reader :countries

  def call!
    countries.each do |country_data|
      next unless country_data.valid?
      country = Country.find_by(code: country_data.code)
      if country
        info "Updating #{country_data})"
        country.update!(country_data.attributes_for_update)
      else
        info "Creating #{country_data})"
        Country.create!(country_data.attributes)
      end
    end

    delete_other_countries
  end

  protected

  def load_countries
    info 'Downloading countries from geonames.org...'
    GeonamesLoader.load_countries
  rescue OpenURI::HTTPError, Timeout::Error
    error 'Download countries failed. Using local static source...'
    load_static_countries
  end

  def delete_other_countries
    Country.where.not(code: countries.map(&:code)).delete_all
  end

  def load_static_countries
    json = JSON.parse(File.read(file_path))
    json['countries'].map(&CountryData.method(:from_hash))
  end

  delegate :info, :error, to: 'Rails.logger'

  private

  def file_path
    Rails.root.join('public', 'countries.json')
  end
end
