class AddReferrerFiltersRequiredToServices < ActiveRecord::Migration
  def change
    add_column :services, :referrer_filters_required, :boolean, default: false
  end
end
