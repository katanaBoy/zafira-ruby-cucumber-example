# frozen_string_literal: true

require 'watir'
require 'fileutils'
require_relative './browser.rb'
require_relative './custom_handlers.rb'

if ENV['HEADLESS']
  require 'headless'
  headless = Headless.new
  headless.start
  at_exit do
    headless.destroy
  end
end

module Cucumber
  class Configuration
    def failed_test_case_handler_class
      FinishedTestCaseHandler
    end
  end
end
