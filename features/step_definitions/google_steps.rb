# frozen_string_literal: true

Given(/opens a browser/) do
  Browser.window
end

Given(/navigates to "([^"]*)"/) do |url|
  Browser.window.goto(url)
end

When(/enters "([^"]*)" to the search bar/) do |search_text|
  Browser.window.send_keys search_text
  Browser.window.send_keys :enter
end

Then(/links related to "([^"]*)" are shown/) do |search_text|
  if Browser.window.elements(text: search_text).size.zero?
    raise "Can't find links related to #{search_text}"
  end
end

Then('google skips searching') do
  skip_this_scenario
end
