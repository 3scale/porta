class ActiveSupport::TimeWithZone # Rails 4.0 only, 4.1 already has a config for this
  # In rails 3 TimeWithZone is like
  # 2015-07-01T00:00:00+02:00
  #
  # But in Rails 4 and above has miliseconds by default, like:
  # 2015-07-01T00:00:00.000+02:00
  #
  # In Rails 4.1 you can set the time precision, e.g. in application.rb
  # ActiveSupport::JSON::Encoding.time_precision = 0
  #
  # Meanwhile redefine the method as_json to get times without miliseconds.
  #
  # This make Rails 4 compatible with our old charts.
  #
  # http://stackoverflow.com/questions/6976650/rails-always-include-the-milliseconds-with-created-at-for-every-model
  # http://apidock.com/rails/v3.2.13/ActiveSupport/TimeWithZone/as_json

  if ActiveSupport::JSON::Encoding.respond_to?(:time_precision)
    ActiveSupport::JSON::Encoding.time_precision = 0
  else
    def as_json(options = nil)
      if ActiveSupport::JSON::Encoding.use_standard_json_time_format
        xmlschema(0)
      else
        %(#{time.strftime("%Y/%m/%d %H:%M:%S")} #{formatted_offset(false)})
      end
    end
  end
end

