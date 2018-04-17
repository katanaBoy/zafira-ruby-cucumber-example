# frozen_string_literal: true

class Browser
  include Singleton

  attr_accessor :browser

  def initialize
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument("--ignore-certificate-errors")
    options.add_argument("--disable-popup-blocking")
    options.add_argument("--disable-translate")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-gpu")
    self.browser = Watir::Browser.new(:chrome, options: options)
  end

  def self.window
    instance.browser
  end
end
