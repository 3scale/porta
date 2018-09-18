require 'app/models/account'

class DefaultAppPlansRemovedForMultiApps < ActiveRecord::Migration
  def self.up
    Account.providers.find_each do |provider|
      if provider.multiple_applications_allowed?
        if master = provider.application_plans.detect{|p| p.master}
          master.update_attribute(:master, false)
          puts "#{master.name} is no longer default"
        end
      end
    end
  end

  def self.down
  end
end
