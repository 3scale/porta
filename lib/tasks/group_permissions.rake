namespace :permissions do
  desc 'seeds the permission system'
  task :seed => ['permissions:destroy:all',
                 'permissions:setup',
                 'permissions:sections:setup',
                 'permissions:groups:full_access',
                 'permissions:members:full_access']

  desc 'creates permissions for all admin sections in the UI'
  task :setup => :environment do
    Permission.create_defaults!
    puts "~ admin side permissions created"
  end

  namespace :sections do
    desc 'Creates the all group types for buyers and providers groups and sections to work'
    task :setup => [:environment, 'sections:partner', 'sections:admin']

    desc 'Creates the group type for buyers groups and sections to work'
    task :partner => :environment do
      require 'app/models/account'
      buyer_gt = GroupType.find_by_buyer_and_provider(true, false)
      name = 'User Account Permissions: groups for API users and partners'

      if buyer_gt.nil?
        GroupType.create!(:name => name, :provider => false, :buyer => true)
        action = "created"
      else
        buyer_gt.update_attribute :name, name
        action = "renamed"
      end
      puts "~ group_type Partner for buyer access to sections #{action}"
    end

    desc 'Creates the group type for provider groups and sections to work'
    task :admin => :environment do
      GroupType.create! :name => 'Admin Account Permissions: groups for our own staff', :provider => true, :buyer => false
      puts "~ group_type Member for provider access to admin sections created"
    end
  end

  namespace :groups do
    desc 'Creates the full_access group for provider members to access all sections'
    task :full_access => :environment do
      grp = Group.create! :name => "Full Access", :group_type_id =>  GroupType.find_by_provider_and_buyer(true, false).id
      Permission.all.each do |perm|
        GroupPermission.create! :group => grp, :permission => perm
      end
      puts "~ group 'full access' containing all permissions created"
    end
  end

  namespace :destroy do
    # Removes everything USE WITH CARE!!
    task :all => ['permissions:destroy:permissions',
                  'permissions:destroy:provider_groups',
                  'permissions:destroy:provider_group_types',
                  'permissions:destroy:group_permissions',
                  'permissions:destroy:group_memberships']

    # Removes all permissions USE WITH CARE!!
    task :permissions => :environment do
      Permission.destroy_all
      puts "~ all Permissions were destroyed"
    end

    # Removes all provider Groups USE WITH CARE!!
    task :provider_groups => :environment do
      prov_gt = GroupType.find_by_provider_and_buyer(true, false)
      if prov_gt
        Group.destroy_all :group_type_id => prov_gt.id
      end
      puts "~ all provider Groups were destroyed"
    end

    # Removes all provider GroupTypes USE WITH CARE!!
    task :provider_group_types => :environment do
      GroupType.find_all_by_provider_and_buyer(true, false)
        .map { |g| g.destroy }
      puts "~ all provider GroupTypes were destroyed"
    end

    # Removes all GroupPermissions USE WITH CARE!!
    task :group_permissions => :environment do
      GroupPermission.destroy_all
      puts "~ all GroupPermissions were destroyed"
    end

    # Removes all GroupMemberships USE WITH CARE!!
    task :group_memberships => :environment do
      UserGroupMembership.destroy_all
      puts "~ all GroupMemberships were destroyed"
    end

  end

  namespace :members do
    desc 'grant full access to all members of provider account'
    task :full_access => :environment do
      provider_id = Account.providers.first.id
      # find the full access group
      full_access_grp_id = Group.find_by_name("Full Access").id
      # make all members belong to it
      User.find_all_by_account_id_and_role(provider_id, "member").map do |user|
        user.user_group_memberships.create! :group_id => full_access_grp_id
      end
      puts "~ all members of provider account are Full Powered"
    end
  end
end
