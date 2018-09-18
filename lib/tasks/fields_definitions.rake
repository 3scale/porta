desc "Changing the extra fields to use fields definitions"
namespace :fields_definitions do

  desc "Copy used fields definitions from provider to master account"
  task :copy_to_master => :environment do
    master = Account.master
    provider = Account.provider

    master_fields = master.fields_definitions.group_by{|fd| [fd.target, fd.name] }
    provider_fields = provider.fields_definitions.group_by{|fd| [fd.target, fd.name] }

    diff = (provider_fields.keys - master_fields.keys).group_by{|tuple| tuple.shift}
    diff.values.each{|arr| arr.flatten! }

    reduce = lambda do |objects|
      objects.map do |object|
        existing = object.class.builtin_fields.map do |field|
          field if object.send(field).present?
        end
        next existing unless fields = object.extra_fields

        existing + fields.map{|k,v| k if v.present? }
      end.flatten.compact.uniq
    end

    defined = {}
    defined['User'] = reduce.call(provider.users)
    defined['Cinstance'] = reduce.call(provider.bought_cinstances)
    defined['Account'] = reduce.call([provider])

    defined.each do |target, attrs|
      Rails.logger.warn "#{target} uses following attributes: #{attrs.to_sentence}"
    end

    missing = Hash[ defined.map{|target, attrs| next unless diff[target]; [target, diff[target] & attrs] } ]

    missing.each do |target, attrs|
      next if attrs.empty?
      Rails.logger.warn "Will create #{attrs.to_sentence} missing attributes for #{target}"
    end

    provider.fields_definitions.each do |fd|
      next unless missing[fd.target].try(:include?, fd.name)

      Rails.logger.warn "Duplicating FieldDefinition with id #{fd.id}"

      clone = fd.dup
      clone.account = master
      clone.save!
    end
  end
end
