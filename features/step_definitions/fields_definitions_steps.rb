Given /^#{PROVIDER} only has the following fields defined for "([^"]*)":$/ do |provider, target, table|
  # first we remove all other optional fields defined (this is what *only* means)
  provider.fields_definitions.by_target("Account").each(&:destroy)
  table.hashes.each do |hash|
    hash.delete_if { |k ,v| v.blank? }
    hash['choices'] = hash['choices'].split( /\s*,*\s/ ) if hash['choices'].is_a? String
    provider.fields_definitions.create! hash.merge!({ :target => target,
                                                      :label => hash["name"].humanize })
  end
end

Given /^#{PROVIDER} has the following fields defined for "([^"]*)":$/ do |provider, target, table|
  table.hashes.each do |hash|
    hash.delete_if { |k ,v| v.blank? }

    if hash['choices'].is_a? String
      hash['choices'] = hash['choices'].split( /\s*,\s*/ )
    end

    provider.fields_definitions.create! hash.merge!(target: target,
                                                    label: hash.fetch('label') { hash.fetch('name').humanize })
  end
end

Given /^(provider "[^"]*") has the field "([^"]*)" for "([^"]*)" in the position (\d+)$/ do |provider, name, klass, pos|
  a = provider.fields_definitions.by_target(klass.underscore).find{ |fd| fd.name == name }
  a.pos = pos
  a.save!
end
