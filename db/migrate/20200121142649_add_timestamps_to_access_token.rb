class AddTimestampsToAccessToken < ActiveRecord::Migration
  def change
    add_timestamps(:access_tokens)
  end
end
