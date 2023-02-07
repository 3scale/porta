# frozen_string_literal: true

require 'test_helper'

class ImportCountriesServiceTest < ActiveSupport::TestCase
  GeonamesLoader = ImportCountriesService::GeonamesLoader
  CountryData = ImportCountriesService::CountryData

  class CountryDataTest < ActiveSupport::TestCase
    setup do
      @country_data = CountryData.new('AR', 'Argentina', 'ARS')
    end

    attr_reader :country_data

    test 'initialize from hash' do
      country_data = CountryData.from_hash(code: 'AR', name: 'Argentina', currency: 'ARS')
      assert_equal 'AR', country_data.code
      assert_equal 'Argentina', country_data.name
      assert_equal 'ARS', country_data.currency
    end

    test 'attributes' do
      attributes = { code: 'AR', name: 'Argentina', currency: 'ARS' }
      assert_equal attributes, country_data.attributes
    end

    test 'attributes for update' do
      now = Time.utc(2020, 2, 3, 8, 0)
      travel_to(now) do
        attributes = { name: 'Argentina', currency: 'ARS', updated_at: now }
        assert_equal attributes, country_data.attributes_for_update
      end
    end

    test '#valid?' do
      assert country_data.valid?

      invalid_country = CountryData.new('AQ', 'Antarctica', '')
      refute invalid_country.valid?
    end

    test '#to_s' do
      assert_equal 'Argentina (AR,ARS)', country_data.to_s
    end
  end

  class GeonamesLoaderTest < ActiveSupport::TestCase
    include WebHookTestHelpers

    test 'load and parse countries' do
      stub_request(:get, 'http://download.geonames.org/export/dump/countryInfo.txt').to_return(status: 200, body: geonames_response)
      countries = GeonamesLoader.load_countries
      expected_countries = [
        { code: 'AR', name: 'Argentina', currency: 'ARS' },
        { code: 'ES', name: 'Spain', currency: 'EUR' },
        { code: 'JP', name: 'Japan', currency: 'JPY' },
        { code: 'NL', name: 'Netherlands', currency: 'EUR' },
        { code: 'US', name: 'United States', currency: 'USD' }
      ]
      assert_equal expected_countries, countries.map(&:to_h)
    end

    private

    def geonames_response
      [
        "#ISO\tISO3\tISO-Numeric\tfips\tCountry\tCapital\tArea(in sq km)\tPopulation\tContinent\ttld\tCurrencyCode\tCurrencyName\tPhone\tPostal Code Format\tPostal Code Regex\tLanguages\tgeonameid\tneighbours\tEquivalentFipsCode",
        "AR\tARG\t032\tAR\tArgentina\tBuenos Aires\t2766890\t41343201\tSA\t.ar\tARS\tPeso\t54\t@####@@@\t^[A-Z]?\\d{4}[A-Z]{0,3}$\tes-AR,en,it,de,fr,gn\t3865483\tCL,BO,UY,PY,BR\t",
        "ES\tESP\t724\tSP\tSpain\tMadrid\t504782\t46505963\tEU\t.es\tEUR\tEuro\t34\t#####\t^(\\d{5})$\tes-ES,ca,gl,eu,oc\t2510769\tAD,PT,GI,FR,MA\t",
        "JP\tJPN\t392\tJA\tJapan\tTokyo\t377835\t127288000\tAS\t.jp\tJPY\tYen\t81\t###-####\t^\\d{3}-\\d{4}$\tja\t1861060\t\t",
        "NL\tNLD\t528\tNL\tNetherlands\tAmsterdam\t41526\t16645000\tEU\t.nl\tEUR\tEuro\t31\t#### @@\t^(\\d{4}\\s?[a-zA-Z]{2})$\tnl-NL,fy-NL\t2750405\tDE,BE\t",
        "US\tUSA\t840\tUS\tUnited States\tWashington\t9629091\t310232863\tNA\t.us\tUSD\tDollar\t1\t#####-####\t^\\d{5}(-\\d{4})?$\ten-US,es-US,haw,fr\t6252001\tCA,MX,CU\t"
      ].join("\n")
    end
  end

  setup do
    GeonamesLoader.stubs(load_countries: country_data)
    @service = ImportCountriesService.new
    service.stubs(delete_other_countries: true)
  end

  attr_reader :service

  test 'load countries' do
    Country.stubs(find_by: nil)
    country_data.select(&:valid?).each { |country| Country.expects(:create!).with(country.attributes) }
    service.call!
  end

  test 'updates countries that already exist' do
    now = Time.utc(2020, 2, 3, 16, 38)
    travel_to(now) do |param|
      japan = Country.new(code: 'JP', name: 'Japan', currency: 'OTH')

      Country.stubs(find_by: nil)
      Country.expects(:find_by).with(code: 'JP').returns(japan)

      country_data.select(&:valid?).reject { |country| country.code == 'JP' }.each { |country| Country.expects(:create!).with(country.attributes) }
      japan.expects(:update_attributes!).with(name: 'Japan', currency: 'JPY', updated_at: now)

      service.call!
    end
  end

  test 'delete countries that are not part of the list' do
    Country.create!(code: 'XX', name: 'Fake Country', currency: 'XXX')
    service.unstub(:delete_other_countries)
    service.call!
    refute Country.find_by(code: 'XX')
  end

  test 'falls back to local static file on 404' do
    GeonamesLoader.unstub(:load_countries)
    stub_request(:get, 'http://download.geonames.org/export/dump/countryInfo.txt').to_return(status: 404) # Causes OpenURI::HTTPError to be raised
    countries = [{ code: 'ES', name: 'Spain', currency: 'EUR' }, { code: 'JP', name: 'Japan', currency: 'JPY' }]
    given_countries_file(countries: countries) do
      service = ImportCountriesService.new
      assert_equal countries, service.countries.map(&:to_h)
    end
  end

  test 'falls back to local static file on timeout' do
    GeonamesLoader.unstub(:load_countries)
    stub_request(:get, 'http://download.geonames.org/export/dump/countryInfo.txt').to_raise(Net::OpenTimeout.new)
    countries = [{ code: 'ES', name: 'Spain', currency: 'EUR' }, { code: 'JP', name: 'Japan', currency: 'JPY' }]
    given_countries_file(countries: countries) do
      service = ImportCountriesService.new
      assert_equal countries, service.countries.map(&:to_h)
    end
  end

  private

  def country_data
    [
      { code: 'AR', name: 'Argentina', currency: 'ARS' },
      { code: 'AQ', name: 'Antarctica', currency: '' }, # invalid
      { code: 'ES', name: 'Spain', currency: 'EUR' },
      { code: 'JP', name: 'Japan', currency: 'JPY' },
      { code: 'NL', name: 'Netherlands', currency: 'EUR' },
      { code: 'US', name: 'United States', currency: 'USD' }
    ].map(&CountryData.method(:from_hash))
  end

  def given_countries_file(json = {})
    FakeFS do
      file_path = Rails.root.join('public', 'countries.json')
      FakeFS::FileSystem.clone(file_path)
      file_path.open('w') { |file| file.puts(json.to_json) }
      yield
    end
  end
end
