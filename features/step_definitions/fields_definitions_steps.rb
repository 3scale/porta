# frozen_string_literal: true

Given "{provider} only has the following fields defined for {string}:" do |provider, target, table|
  # first we remove all other optional fields defined (this is what *only* means)
  provider.fields_definitions.by_target("Account").each(&:destroy)
  table.hashes.each do |hash|
    hash.delete_if { |k ,v| v.blank? }
    hash['choices'] = hash['choices'].split( /\s*,*\s/ ) if hash['choices'].is_a? String
    provider.fields_definitions.create! hash.merge!({ target: target,
                                                      label: hash['Name'].humanize })
  end
end

Given "{provider} has the following fields defined for {string}:" do |provider, target, table|
  table.hashes.each do |hash|
    hash.delete_if { |k ,v| v.blank? }

    hash['choices'] = hash['choices'].split( /\s*,\s*/ ) if hash['choices'].is_a? String

    provider.fields_definitions.create! hash.merge!(target: target,
                                                    label: hash.fetch('label') { hash.fetch('name').humanize })
  end
end

Given "{provider} has the field {string} for {string} in the position {int}" do |provider, name, klass, pos|
  a = provider.fields_definitions.by_target(klass.underscore).find{ |fd| fd.name == name }
  a.pos = pos
  a.save!
end
