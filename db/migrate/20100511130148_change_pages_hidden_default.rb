class ChangePagesHiddenDefault < ActiveRecord::Migration
  def self.up
    change_column_default :pages, :hidden, nil
  end

  def self.down
    change_column_default :pages, :hidden, false
  end
end
