# frozen_string_literal: true

module ThreeScale
  class TenantIDIntegrityChecker
    attr_reader :tenant_id

    def initialize(attribute = :tenant_id)
      @attribute = attribute
    end

    def check
      processed = []

      models_with_tenant_id.inject([]) do |inconsistent_found, model|
        Rails.logger.info "Tenant integrity of #{model}"
        inconsistent_found.concat associated_inconsistent_pairs(model, processed: processed)
      end
    end

    private

    def associated_inconsistent_pairs(model, processed: [])
      model.reflect_on_all_associations.inject([]) do |inconsistent_found, association|
        next inconsistent_found if can_skip_asociation?(association, processed: processed)

        processed << association

        inconsistent_found.concat inconsistent_pairs_for(model, association)
      end
    end

    def inconsistent_pairs_for(model, association)
      table = model.arel_table.name
      table_alias = last_table_alias_from_sql(model.joins(association.name).to_sql)
      found = model.joins(association.name).where.not("#{table_alias}.tenant_id = #{table}.tenant_id")
      found = found.merge(Account.where(provider: false).or(Account.where(provider: nil))) if model == Account && association.name == :provider_account
      found = pluck_pks(found, association: association, table: table, assoc_table: table_alias)
      found.map { ["#{model}#{_1}", association.name, "#{association.klass}#{_2}"] }
    end

    def pluck_pks(joined_relation, association:, assoc_table:, table:)
      model_pk = pk_fields association.active_record
      assoc_pk = pk_fields association.klass
      res = joined_relation.reorder('').pluck(*model_pk.map{"#{table}.#{_1}"}, *assoc_pk.map{"#{assoc_table}.#{_1}"})
      res.map { [_1.slice(0, model_pk.size), _1.slice(model_pk.size..-1)] }
    end

    def pk_fields(model)
      # in oracle-enhanced model.connection.schema_cache.primary_keys returns nil for composite so can't use the cache
      model.primary_key ? Array(model.primary_key) : model.connection.primary_keys(model.table_name)
    end

    def can_skip_asociation?(association, processed: [])
      # we can ignore these as they can't be automatically excluded but are redundant for the check anyway
      ignored = {
        Service => %i[all_metrics], # all metrics of service and APIs used by service so is redundant
        Account => %i[provider_accounts], # only master has this and it is normal that all will mismatch
      }
      model = association.active_record

      return true if ignored[model]&.include?(association.name)

      # we live in a perfect world where all associations have an inverse so we can skip polymorphic ones
      return true if association.polymorphic?

      # arity can be one when association has a scope defined with a proc taking current object as argument
      # We can't handle such associations but we can ignore them if the inverse one we can handle
      if association.scope&.arity&.public_send(:>, 0)
        return true unless association.inverse_of.polymorphic? || association.inverse_of.scope&.arity&.public_send(:>, 0)
        raise "we can't handle #{association.name} of #{model}"
      end

      return true unless association.klass.attribute_names.include?("tenant_id")

      # skip indirect associations where the "through association" has tenant_id, because we will check that
      #   indirect association through the "through association" later (or we did already)
      return true if association.through_reflection&.try(:klass)&.attribute_names&.include?("tenant_id")

      processed.any? {_1 == association || _1 == association.inverse_of }
    end

    def last_table_alias_from_sql(sql)
      matcher = /.*INNER JOIN [`'"]([\S]+)[`'"] (?:[`'"]([\S]+)[`'"] )?ON/i.match(sql)
      matcher[2] || matcher[1]
    end

    def models_with_tenant_id
      Rails.autoloaders.main.eager_load_dir("#{Rails.root}/app/models")
      all_models = ApplicationRecord.descendants.select(&:arel_table).reject(&:abstract_class?)
      all_models.select! { _1.attribute_names.include? "tenant_id" }
    end
  end
end
