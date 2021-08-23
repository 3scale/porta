# frozen_string_literal: true

ActiveSupport.on_load(:active_record) do

require 'previously_changed'

ActiveRecord::Base.send(:include, PreviouslyChanged)

end
