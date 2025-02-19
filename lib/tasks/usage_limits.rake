# frozen_string_literal: true

namespace :usage_limits do
  desc 'Deletes instances of UsageLimit for metrics of a backend, that is not linked to the product of the plan anymore'
  # see issue https://issues.redhat.com/browse/THREESCALE-11631
  task clean_orphans: :environment do
    orphan_usage_limits = UsageLimit
                            .joins('INNER JOIN metrics ON metrics.id = usage_limits.metric_id')
                            .joins('INNER JOIN plans ON usage_limits.plan_id = plans.id')
                            .where("metrics.owner_type = 'BackendApi'")
                            .where("NOT EXISTS (SELECT 1 FROM backend_api_configs bac WHERE bac.service_id = plans.issuer_id AND bac.backend_api_id = metrics.owner_id)")

    count = orphan_usage_limits.count
    puts "Found #{count} orphan usage limits in the database"

    if count.positive?
      orphan_usage_limits.destroy_all

      puts "Deleted #{count} instances of FeaturesPlan from the database."
    end
  end
end
