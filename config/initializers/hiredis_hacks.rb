# frozen_string_literal: true

# Monkey patches hiredis so connections errors with exception class `RuntimeError` and
# message "Name or service not known" (i.e. name solving problems) are properly handled
# as `Redis::BaseConnectionError` errors, which will be caught by `Redis::Client#establish_connection`

module HiredisHacks
  module Connection
    def connect(*args)
      super
    rescue RuntimeError => exception
      if exception.message =~ /Name or service not known|nodename nor servname provided, or not known/
        raise Redis::BaseConnectionError.new("#{exception.message} (#{exception.class})")
      else
        raise
      end
    end
  end
end

Hiredis::Connection.prepend(HiredisHacks::Connection)
