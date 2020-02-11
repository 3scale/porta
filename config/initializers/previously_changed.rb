# frozen_string_literal: true

require 'previously_changed'

ActiveRecord::Base.send(:include, PreviouslyChanged)
