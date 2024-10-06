# It's easy to add more libraries or choose different versions. Any libraries
# specified here will be installed and made available to your morph.io scraper.
# Find out more: https://morph.io/documentation/ruby

source "https://rubygems.org"

ruby "3.3.5"

# Handle morph copying Gemfile without .ruby-version - check they are in sync when we can
ruby_version_file = File.join(__dir__, '.ruby-version')
if File.exist?(ruby_version_file) && File.read(File.join(__dir__, '.ruby-version')).strip != RUBY_VERSION
  raise ".ruby-version should be set to ruby version: #{RUBY_VERSION}"
end

gem "scraperwiki", git: "https://github.com/openaustralia/scraperwiki-ruby.git", branch: "morph_defaults"
gem 'capybara'
gem "selenium-webdriver"
gem 'capybara-shadowdom'

# Fix install on ubuntu Noble
#gem 'nokogiri', '>= 1.16.7'
