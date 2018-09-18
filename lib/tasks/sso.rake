namespace :sso do

  desc "one time"
  task :randomize_impersonation_admin_password => :environment do
    User.impersonation_admins.find_each(batch_size: 25) do | user |
      puts "** generating a new password (provider=#{user.account.try(:org_name) || '-- no provider. why?!?'})"
      # XXX> when we're ready
      password = SecureRandom.hex
      print "\t#{password}"
      user.password = user.password_confirmation = password
      if user.save
        print " -- [\033[1;32mOK\033[0m]\n"
      else
        print " -- [\033[1;31mNOT OK\033[0m]: #{user.errors.full_messages.join(', ')}\n"
      end
    end
  end

  desc "generates sso keys for all providers that don't have one"
  task :generate_sso_keys => :environment do
    Account.providers_with_master.includes(:settings).where("settings.sso_key is null").find_each(batch_size: 50) do | provider |
      print "** generating an sso_key for provider: #{provider.org_name}..."
      provider.settings.update_attribute :sso_key, ThreeScale::SSO.generate_sso_key
      puts " #{provider.settings.sso_key}"
    end
  end

  desc "overwrites an sso_key for given provider"
  task :generate_sso_key, [:account_id] => :environment do | t, args |
    settings= Account.providers_with_master.find(args[:account_id]).settings
    puts "** overwriting sso_key: `#{settings.sso_key}' for provider: #{args[:account_id]}."
    settings.generate_sso_key
    settings.save!
    puts "** generated a new sso_key: `#{settings.sso_key}' for provider #{args[:account_id]}."
  end
end
