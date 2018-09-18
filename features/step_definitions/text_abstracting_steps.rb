{
  "Look and feel" => 'Look and Feel',
  "Settings" => 'Settings',
  "Site" => 'Site',
  "Portal" => 'Portal',
  "Terms" => 'Terms',
  "Policies" => 'Policies',
  "Apps Gallery" => 'Apps Gallery'
}.each do |identifier, text|

  Then /^I should see the link #{identifier}$/ do
    step %{I should see the link "#{text}"}
  end

  Then /^I should not see the link #{identifier}$/ do
    step %{I should not see the link "#{text}"}
  end
end
