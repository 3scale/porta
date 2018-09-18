
Then /^the current page should link a stylesheet "([^"]*)" with timestamp (.+)$/ do |name, timestamp|
  timestamp = Time.zone.parse(timestamp).to_i

  link = all('link[rel = "stylesheet"]').find { |node| node[:href].include?(name) }
  assert link[:href].ends_with?("?#{timestamp}"),
         %(Expected the path "#{link[:href]}" to end with "?#{timestamp}")
end
