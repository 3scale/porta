desc 'Show all keys (private_provider, public_provider and user) of all cinstances of account whose name is given as parameter NAME (substring match, case insensitive)'
task :keys => :environment do
  Account.find(:all,
    :conditions => ENV['NAME'].blank? ? nil : ['org_name LIKE ?', "%#{ENV['NAME']}%"],
    :order => 'org_name'
              ).each do |account|
    next if account.bought_cinstances.empty?

    puts "#{account.org_name}:"

    account.bought_cinstances.each do |cinstance|
      puts ""
      puts "\t#{cinstance.contract.service.name} (#{cinstance.contract.name}):"
      puts "\t\tprovider_private_key:\t#{cinstance.contract.service.provider_private_key}"
      puts "\t\tprovider_public_key:\t#{cinstance.provider_public_key}"
      puts "\t\tuser_key:\t\t#{cinstance.user_key}"
    end
  end
end
