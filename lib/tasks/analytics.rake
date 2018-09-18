
namespace :analytics do
  desc 'Move master account cinstances to analytics service'
  task :move_all => :environment do
    master = Account.find_by_master true
    analytics_plan_id = master.services.find_by_name('Analytics').plans[0].id

    master.first_service!.cinstances.each do |c|
      c.update_attribute(:plan_id, analytics_plan_id)
    end
  end
end
