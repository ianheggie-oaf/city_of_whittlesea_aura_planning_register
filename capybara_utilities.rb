# Handle the interface with Capybara and chrome in these methods

require 'net/http'

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

  def create_capybara_session
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless') if headless
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')

    Capybara.register_driver :custom_chrome do |app|
      Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
    end

    Capybara::Session.new(:custom_chrome)
  end

  def visit_url(url)
    session = create_capybara_session
    session.visit(url)
    session
  end

  def visit_with_retry(url)
    visit_url(url)
  rescue Selenium::WebDriver::Error::WebDriverError => e
    error "Error visiting URL: #{e.message}"
    info "Attempting to update ChromeDriver with default version and retry..."
    require 'webdrivers'
    begin
      Webdrivers::Chromedriver.update
      visit_url(url)
    rescue Selenium::WebDriver::Error::WebDriverError, Webdrivers::VersionError => e
      error "Error retrying to visit URL: #{e.message}"
      info "Attempting to determine required chromedriver to update ChromeDriver and retry..."
      chrome_version = get_chrome_version
      info "Found chrome version: #{chrome_version}"
      chromedriver_version = find_latest_compatible_chromedriver(chrome_version)
      info "Found compatible ChromeDriver version: #{chromedriver_version}"
      Webdrivers::Chromedriver.required_version = chromedriver_version if chromedriver_version
      Webdrivers::Chromedriver.update
      visit_url(url)
    end
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
