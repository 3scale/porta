# frozen_string_literal: true

ActiveSupport.on_load(:active_record) do
  require 'three_scale/lazy_initialization'
  ActiveRecord::Base.send(:include, ThreeScale::LazyInitialization)
end
