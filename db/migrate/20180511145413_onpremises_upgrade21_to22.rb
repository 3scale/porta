# frozen_string_literal: true

require 'three_scale/upgrades/from_21_to_22'

class OnpremisesUpgrade21To22 < ActiveRecord::Migration
  def up
    ThreeScale::Upgrades::From21To22.run
  end
end
