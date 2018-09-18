require 'open-uri'

namespace :countries do

  desc "Import countries from Geonames repository"
  task :import => :environment do
    started_at = Time.zone.now
    puts "-- downloading..."
    doc = open("http://download.geonames.org/export/dump/countryInfo.txt")
    # Ignore these invalid/obsolete countries:
    ignore = %w[CS XK AQ UM] # Serbia and Montenegro, Kosovo (not there yet), Antartica
    puts "-- parsing..."
    doc.readlines.each do | line |
      next if line.starts_with?("#") # comment.
      row= line.split("\t")
      code = row[0]
      next if ignore.include?(code)
      name = row[4]
      currency = row[10]

      if country= Country.find_by_code(code)
        puts "-- updating #{name} (#{code},#{currency})"
        country.update_attributes! :name => name, :currency => currency, :updated_at => Time.zone.now
      else
        puts "-- creating #{name} (#{code},#{currency})"
        Country.create! :name => name, :code => code, :currency => currency
      end
    end

    Country.delete_all ["updated_at < ?", started_at]
  end

  desc 'Disable T5 countries'
  task :disable_t5 => :environment do
    Country.t5_countries.update_all(enabled: false)
  end

end
