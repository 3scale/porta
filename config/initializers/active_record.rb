# TODO: remove this hack?
require 'deadlock_retry'
class ActiveRecord::Base

  # returns a human readable name of the class.
  # It is here mainly to allow Cinstance to return "Application"
  def human_name
    self.to_s
  end
end
