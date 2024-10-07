# Handle the interface with Capybara and chrome in these methods

require 'net/http'

module CapybaraUtilities
  def get_chrome_version
    chrome_version = nil
    ['google-chrome', 'chromium', 'chromium-browser'].each do |browser|
      version = `#{browser} --version 2>/dev/null`.strip
      if $?.success?
        chrome_version = version.split.last
        break
      end
    end

    if chrome_version
      chrome_version.split('.').first  # Return major version number
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

  def visit_with_retry(url)
    retries = 0
    max_retries = 2

    begin
      raise Selenium::WebDriver::Error::WebDriverError, "force" if retries == 0 && ENV['FORCE_RETRY']
      session = create_capybara_session
      session.visit(url)
      session
    rescue Selenium::WebDriver::Error::WebDriverError, Webdrivers::VersionError => e
      error "Error visiting URL: #{e.message}"
      require 'webdrivers'
      if retries < max_retries
        retries += 1
        info "Attempting to update ChromeDriver and retry... (Attempt #{retries} of #{max_retries})"

        begin
          Webdrivers::Chromedriver.update
        rescue Webdrivers::VersionError => ve
          error "Version error: #{ve.message}"
          begin
            chrome_version = get_chrome_version
            chromedriver_version = find_latest_compatible_chromedriver(chrome_version)

            if chromedriver_version
              info "Found compatible ChromeDriver version: #{chromedriver_version}"
              Webdrivers::Chromedriver.required_version = chromedriver_version
              Webdrivers::Chromedriver.update
            else
              error "Unable to find a compatible ChromeDriver version"
            end
          rescue StandardError => e
            error "Error determining browser version: #{e.message}"
          end
        end

        retry
      else
        raise "Failed to visit URL after #{max_retries} attempts: #{e.message}"
      end
    end
  end

  def find_latest_compatible_chromedriver(chrome_version)
    major_version = chrome_version.to_i
    while major_version > 0
      url = "https://chromedriver.storage.googleapis.com/LATEST_RELEASE_#{major_version}"
      response = Net::HTTP.get_response(URI(url))
      if response.is_a?(Net::HTTPSuccess)
        return response.body.strip
      end
      major_version -= 1
    end
    nil
  end

end
