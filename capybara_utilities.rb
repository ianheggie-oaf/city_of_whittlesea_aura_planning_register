# Handle the interface with Capybara and chrome in these methods

require 'net/http'
require 'webdrivers/chromedriver'

module CapybaraUtilities
  def get_chrome_version
    chrome_version = nil
    %w[google-chrome chromium chromium-browser].each do |browser|
      version = `#{browser} --version 2>/dev/null`.strip
      if $?.success?
        chrome_version = version.split.last
        break
      end
    end

    if chrome_version
      chrome_version.split('.').first # Return major version number
    else
      raise "Unable to determine Chrome or Chromium version"
    end
  end

  def find_driver_path
    # Force resolution of the driver path and possible update now to avoid triggering VCR
    ::Webdrivers::Chromedriver.update
  rescue ::Webdrivers::VersionError => ex
    raise unless ex.message =~ /Unable to find latest point release version for (\d+)\./
    $1.to_i.downto(100) do |major_ver|
      uri = URI("https://chromedriver.storage.googleapis.com/LATEST_RELEASE_#{major_ver}")
      res = Net::HTTP.get_response(uri)
      next unless res.is_a?(Net::HTTPSuccess)

      ver = res.body.chomp
      puts "Using chromdriver version: #{ver} due to: #{ex.message}"
      Webdrivers::Chromedriver.required_version = ver
      return ::Webdrivers::Chromedriver.update
    end
    nil
  end

  def setup_webdriver
    driver_path = find_driver_path
    puts "Using chrome driver path: #{driver_path.inspect} ..."
    ::Selenium::WebDriver::Chrome::Service.driver_path = driver_path

    Capybara.register_driver :logging_selenium do |app|
      # caps = # Selenium::WebDriver::Remote::Capabilities.chrome(loggingPrefs: { browser: 'ALL' })
      #   Selenium::WebDriver::Remote::Capabilities.chrome("goog:loggingPrefs": { browser: 'ALL' })
      browser_options = ::Selenium::WebDriver::Chrome::Options.new
      if ENV['DISPLAY'].nil? || ENV['HEADLESS']
        browser_options.args << '--headless' # add whatever browser args and other options you need (--headless, etc)
      end
      browser_type = determine_browser_type
      puts "Calling Capybara::Selenium::Driver.new(app, browser: #{browser_type.inspect}, options: #{browser_options.inspect})" # , desired_capabilities: #{caps.inspect})"
      Capybara::Selenium::Driver.new(app, browser: browser_type, options: browser_options) # , desired_capabilities: caps)
    end
  end

  def determine_browser_type
    %w[google-chrome chromium chromium-browser].each do |browser|
      version = `#{browser} --version 2>/dev/null`.strip
      if $?.success?
        return browser.include?('chromium') ? :chromium : :chrome
      end
    end
    :chrome # Default to Chrome if we can't determine
  end

  def create_capybara_session(retry_attempt: false)
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless') if headless
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')
    options.add_argument('--enable-logging --v=1 --log-path=/tmp/chrome_debug.log')

    driver_name = if retry_attempt
                    :logging_selenium
                  else
                    headless ? :chrome_headless : :selenium_chrome
                  end
    Capybara::Session.new(driver_name)
  end

  def visit_url(url, retry_attempt: false)
    session = create_capybara_session(retry_attempt: retry_attempt)
    session.visit(url)
    session
  rescue Selenium::WebDriver::Error::WebDriverError => e
    if retry_attempt
      error "Chrome failed to start on retry: #{e.message}"
      # error "Chrome logs:"
      # error `cat /tmp/chrome_debug.log`
    end
    raise e
  end

  def visit_with_retry(url)
    visit_url(url)
  rescue Selenium::WebDriver::Error::WebDriverError => e
    error "Error visiting URL: #{e.message}"
    info "Attempting to update ChromeDriver and retry..."
    setup_webdriver
    visit_url(url, retry_attempt: true)
  end

  def find_latest_compatible_chromedriver(chrome_version)
    major_version = chrome_version.to_i
    puts "Chrome major version is: #{major_version}"
    while major_version > 0
      url = "https://chromedriver.storage.googleapis.com/LATEST_RELEASE_#{major_version}"
      response = Net::HTTP.get_response(URI(url))
      if response.is_a?(Net::HTTPSuccess)
        puts "Found Chromedriver major version: #{major_version}"
        return response.body.strip
      end
      puts "Failed Chromedriver major version: #{major_version}, will try next lower"
      major_version -= 1
    end
    nil
  end

end
