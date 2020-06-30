# frozen_string_literal: true

class RemoveProxyColumns < ActiveRecord::Migration[5.0]
  def up
    safety_assured { remove_column(:proxies, :api_backend) }
  end
end
