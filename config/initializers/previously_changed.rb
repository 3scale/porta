require 'previously_changed'

ActiveRecord::Base.send(:include, PreviouslyChanged)
