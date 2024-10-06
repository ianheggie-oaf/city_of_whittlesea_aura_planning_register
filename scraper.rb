#!/usr/bin/env ruby

# This is a template for a Ruby scraper on morph.io (https://morph.io)
# including some code snippets below that you should find helpful

REGISTER_FORM_URL = 'https://online.whittlesea.vic.gov.au/s/publicregister'
INFO_URL_PREFIX = 'https://online.whittlesea.vic.gov.au/s/applicationpageforpr?recordId='

EXTRA_WAIT_FOR_AJAX = 5

DAYS_INTO_PAST = 30

DEFAULT_TIMEOUT = 30

begin
  # Use the gem versions from Gemfile.lock
  require 'bundler/setup'
  Bundler.require(:default)
rescue Bundler::LockfileError => e
  $stderr.puts "WARING: Ignoring bundle lock failure: #{e.message}"
  require 'scraperwiki'
  require 'capybara'
  require 'selenium-webdriver'
  require 'capybara-shadowdom'
end

require 'date'
require 'yaml'
require 'uri'

require_relative 'log_helper'
require_relative 'scraper_utilities'

class Scraper
  include LogHelper
  include ScraperUtilities

  def headless
    false # ENV['HEADED'].to_s == ''
  end

  def capybara_driver
    Capybara.ignore_hidden_elements = false
    Capybara::Session.new(headless ? :selenium_chrome_headless : :selenium_chrome)
  end

  def capture_ajax_response(capybara)
    capybara.execute_script(<<~JS)
      window.lastAjaxResponse = null;
      (function(open) {
        XMLHttpRequest.prototype.open = function() {
          this.addEventListener("load", function() {
            if (this.readyState === 4) {
              window.lastAjaxResponse = this.responseText;
            }
          });
          open.apply(this, arguments);
        };
      })(XMLHttpRequest.prototype.open);
    JS

    yield # Perform the action that triggers the AJAX call

    capybara.evaluate_script('window.lastAjaxResponse')
  end

  def current_time_with_ms
    Time.now.strftime("%Y-%m-%d %H:%M:%S.%L  %z")
  end

  def search_within_date_range(capybara, from_date, to_date)
    date_format = '%d/%m/%Y'
    # puts from_date.strftime(date_format)
    capybara.fill_in "From Date", with: from_date.strftime(date_format)
    capybara.fill_in "To Date", with: to_date.strftime(date_format)
    debug "About to press Search ..."
    response_json = capture_ajax_response(capybara) do
      capybara.click_on "Search", visible: true
      debug "Waiting for table to appear at #{current_time_with_ms}"
      wait_for_table_present(capybara)
      debug "Waiting additional #{EXTRA_WAIT_FOR_AJAX} seconds for ajax response at #{current_time_with_ms} ..."
      sleep EXTRA_WAIT_FOR_AJAX
    end
    JSON.parse(response_json)
  end

  def table_present?(capybara)
    start_node = capybara.find('body')
    paths = ["c-search-public-register", "lightning-datatable", "tbody tr"]
    trs = find_all_nodes_with_paths(start_node, paths)
    trs && trs.size > 0
  rescue Capybara::ElementNotFound
    false
  end

  def wait_for_table_present(capybara, timeout: DEFAULT_TIMEOUT)
    Timeout.timeout(timeout) do
      slept = 0.0
      until table_present?(capybara)
        sleep(0.1)
        slept += 0.1
      end
      debug "Slept #{slept} seconds waiting for table to appear"
    end
  rescue Timeout::Error
    error "Table did not appear within #{timeout} seconds"
  end

  def process_entry(entry, record_number, date_scraped)
    debug "Processing record ##{record_number} ..."
    application_number = entry['Name']
    property_address = entry['Property_Address__c']
    description = nil
    # Multiple keys:
    # Description_of_the_Amendment__c
    # Description_of_the_Development__c
    entry.each do |key, value|
      next unless key.start_with? 'Description'

      description = "#{description}  #{value}".strip
    end
    id = entry['Id']
    info_url = "#{INFO_URL_PREFIX}#{URI.encode_www_form_component(id)}" if id.to_s != ''

    # Parent Application Number -
    date_string = entry['Submitted_Date__c']
    submitted_date = begin
                       Date.parse(date_string).to_s
                     rescue Date::Error
                       warn "Skipping record with invalid date: #{date_string.inspect}"
                       return false
                     end

    # on_notice_from - There is a "Advertising Date" on the View page, but I didn't see any examples to determine key
    # on_notice_to

    record = {
      council_reference: application_number,
      address: property_address,
      description: description,
      info_url: info_url,
      date_scraped: date_scraped,
      date_received: submitted_date,
    }
    if record.values.any? { |value| value.to_s == '' }
      warn "Skipping record with empty value/s: #{record.inspect}"
      return false
    end

    debug "Record so far: #{record.inspect}"

    ScraperWiki.save_sqlite([:council_reference], record)
    true
  end

  def data_count
    table = ScraperWiki.select("count(*) as count from data")
    table.first.values.first
  rescue => e
    warn "data_count: Ignoring: #{e} [returning 0]"
    0
  end

  def main
    debug "Noting before record count ..."
    before_count = data_count
    info "DB has #{before_count} records."
    processed = skipped = 0
    debug "Initialising capybara ..."
    capybara = capybara_driver
    list = nil
    begin
      info "Visiting website using capybara ..."
      capybara.visit(REGISTER_FORM_URL)
      to_date = Date.today
      from_date = to_date - DAYS_INTO_PAST
      ajax_response = search_within_date_range(capybara, from_date, to_date)
      ajax_response['actions']&.each do |action|
        unless action['state'] == 'SUCCESS'
          error "Failed: Action failed with state: #{action['state']}!"
          exit 1
        end

        list = begin
                 action.fetch('returnValue').fetch('returnValue')
               rescue => e
                 error "Failed: failed to retrieve returnValue.returnValue from #{action.to_yaml}!"
                 raise
               end
      end
    ensure
      info "Quitting capybara"
      capybara.quit
    end
    unless list.is_a? Array
      error "Failed: Expected action.returnValue.returnValue to be an array: #{action['state']}!"
      exit 2
    end

    date_scraped = Date.today.to_s
    list.each_with_index do |entry, index|
      debug "ENTRY: #{entry.to_yaml}"
      if process_entry(entry, index + 1, date_scraped)
        processed += 1
      else
        skipped += 1
      end
    end
    debug "Noting after record count ..."
    after_count = data_count
    info "DB has #{after_count} records."
    added = after_count - before_count
    info "Processed #{processed} and Skipped #{skipped} Records, Adding #{added} new records to DB."
  end
end

Scraper.new.main
