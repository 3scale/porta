# frozen_string_literal: true

namespace :db do
  namespace :toggle_visibility do

    desc 'Toggle "in-use" account plans visibility'
    task :account => :environment do

      Account.providers.select{|a| 1<a.account_plans.count}.each{|i| i.settings.toggle!(:account_plans_ui_visible)}
    end

    desc 'Toggle "in-use" service plans visibility'
    task :service => :environment do

      Account.providers.select{|a| 1<a.service_plans.count}.each{|i| i.settings.toggle!(:service_plans_ui_visible)}
    end
  end
end
