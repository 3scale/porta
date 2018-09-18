class PrefixApiKeys < ActiveRecord::Migration
  def self.up
    execute("UPDATE cinstances SET user_key = CONCAT('3scale-', user_key)
             WHERE user_key NOT LIKE '3scale-%'")

    execute("UPDATE cinstances SET provider_public_key = CONCAT('3scale-', provider_public_key)
             WHERE provider_public_key NOT LIKE '3scale-%'")

    execute("UPDATE services SET provider_private_key = CONCAT('3scale-', provider_private_key)
             WHERE provider_private_key NOT LIKE '3scale-%'")
  end

  def self.down
    execute("UPDATE cinstances SET user_key = SUBSTRING(user_key, 8)
             WHERE user_key LIKE '3scale-%'")

    execute("UPDATE cinstances SET provider_public_key = SUBSTRING(provider_public_key, 8)
             WHERE provider_public_key LIKE '3scale-%'")

    execute("UPDATE services SET provider_private_key = SUBSTRING(provider_private_key, 8)
             WHERE provider_private_key LIKE '3scale-%'")
  end
end
