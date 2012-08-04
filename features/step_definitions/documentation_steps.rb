When /^I load Raddocs$/ do
  @raddocs = Capybara::Session.new(:rack_test, Raddocs::App.new)
  @raddocs.visit "/"
end

Then /^the following (.*?) examples should be listed:$/ do |resource, table|
  @raddocs.should have_content(resource)
end

When /^I view documentation for "(.*?)"$/ do |example|
  @raddocs.click_link example
end

Then /^the request route should be "(.*?)"$/ do |route|
  @raddocs.should have_css(".request .route .route", :text => route)
end

Then /^the response status should be (\d+)$/ do |status|
  @raddocs.should have_css(".response .status .status", :text => status)
end

Then /^the response headers should be:$/ do |table|
  headers = table.raw.map { |row| row.join(": ") }.join("\n")
  @raddocs.should have_css(".response .headers .headers", :text => headers)
end

Then /^the response body should be "(.*?)"$/ do |body|
  @raddocs.should have_css(".response .body .content", :text => body)
end
