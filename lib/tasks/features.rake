namespace :features do
  desc 'Deletes instances of FeaturesPlan whose ids point to non-existing features'
  task :clean_orphan_features_plan => :environment do
    fids = Feature.pluck(:id)

    puts("Found #{fids.count} features in the database")

    count = FeaturesPlan.where(["feature_id NOT in (?)", fids]).delete_all

    puts("Deleted #{count} instances of FeaturesPlan from the database.")
  end
end

