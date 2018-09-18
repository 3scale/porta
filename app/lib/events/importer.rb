require_dependency 'events/event'

require_dependency 'events/importers/base_importer'
require_dependency 'events/importers/first_traffic_importer'
require_dependency 'events/importers/first_daily_traffic_importer'
require_dependency 'events/importers/alert_importer'

module Events
  module Importer

    def self.async_import_event!(event_attrs)
      EventImportWorker.perform_async(event_attrs)
    end

    def self.import_event!(event_attrs)
      event = Event.new(event_attrs)
      Rails.logger.info("importing #{event.type} event: #{event}")

      self.for(event).save!

    rescue ActiveRecord::RecordNotFound => not_found
      # ignore deleted objects
      Rails.logger.error("exception raised: #{not_found} when importing #{event}")
      System::ErrorReporting.report_error not_found, :parameters => {:event => event}

    rescue StandardError => error
      Rails.logger.error("unknown error raised: #{error} when importing #{event}")
      System::ErrorReporting.report_error error, :parameters => { :event => event }
    end

    def self.for(event)
      object = event.object

      case type = event.type
      when 'alert'
        Importers::AlertImporter.new(object)
      when 'first_traffic'
        Importers::FirstTrafficImporter.new(object)
      when 'first_daily_traffic'
        Importers::FirstDailyTrafficImporter.new(object)
      else
        raise "Unknown event importer for type: #{type.inspect}"
      end
    end

    def self.clear_services_cache
      Importers::BaseImporter.clear_cache
    end

  end
end
