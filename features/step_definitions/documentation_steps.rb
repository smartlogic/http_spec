When /^I load Raddocs$/ do
  @raddocs = Capybara::Session.new(:rack_test, Raddocs::App.new)
  @raddocs.visit "/"
end

Then /^the following (.*?) examples should be listed:$/ do |resource_name, table|
  resource = @raddocs.all(".resource").detect do |resource|
    resource.find("h2").text == resource_name
  end
  actual = resource.all(".example").map { |example| example.text.strip }
  expected = table.raw.map(&:first)
  expect(actual).to eq(expected)
end

When /^I view documentation for "(.*?)"$/ do |example|
  @raddocs.click_link example
end

Then /^the parameters should be:$/ do |table|
  actual = @raddocs.find(".parameters").all(".parameter").map do |parameter|
    name = parameter.find(".name").text
    description = parameter.find(".description").text
    [name, description]
  end
  expected = table.raw
  expect(actual).to eq(expected)
end

Then /^the request route should be "(.*?)"$/ do |route|
  expect(@raddocs).to have_css(".request .route .route", :text => route)
end

Then /^the response status should be (\d+)$/ do |status|
  expect(@raddocs).to have_css(".response .status .status", :text => status)
end

Then /^the response headers should be:$/ do |table|
  table.raw.each do |row|
    expect(@raddocs).to have_css(".response .headers .headers", :text => row.join(": "))
  end
end

Then /^the response body should be "(.*?)"$/ do |body|
  expect(@raddocs).to have_css(".response .body .content", :text => body)
end
