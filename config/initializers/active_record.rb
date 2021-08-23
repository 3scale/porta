ActiveSupport.on_load(:active_record) do

  # shall we still rely on this abandoned in 2012 retry code?
  require 'deadlock_retry'

  class ActiveRecord::Base

    # returns a human readable name of the class.
    # It is here mainly to allow Cinstance to return "Application"
    def human_name
      self.to_s
    end
  end
end
