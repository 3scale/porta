# frozen_string_literal: true

class AddActsAsProductToService < ActiveRecord::Migration
  def up
    add_column :services, :act_as_product, :boolean
    change_column_default :services, :act_as_product, false
  end

  def down
    remove_column :services, :act_as_product
  end
end
