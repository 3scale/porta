# frozen_string_literal: true

require 'three_scale/lazy_initialization'
ActiveRecord::Base.send(:include, ThreeScale::LazyInitialization)
