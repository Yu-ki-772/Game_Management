# spec/support/capybara.rb
require "selenium-webdriver"

Capybara.disable_animation = true

Capybara.register_driver :headless_chromium do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument("--headless=new")
  options.add_argument("--no-sandbox")
  options.add_argument("--disable-dev-shm-usage")
  options.add_argument("--disable-gpu")

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :headless_chromium, screen_size: [ 1400, 1400 ]
  end

end