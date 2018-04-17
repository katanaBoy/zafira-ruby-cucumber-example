# Zafira ruby cucumber integration using Jenkins

An example of using gem `zafira-ruby` https://github.com/qaprosoft/zafira-ruby

## How to

### Using Qaprosoft infrastructure https://github.com/qaprosoft/qps-infra

Please read how to setup qps-infra https://github.com/qaprosoft/qps-infra

Then create a freestyle project in Jenkins.
Following settings should be set before run:
- Source Code Management
  - Git
    - Repository URL. It's a cucumber tests repository. Currently we use `https://github.com/qaprosoft/zafira-ruby-cucumber-integration`.
    - Branch Specifier (blank for 'any'). A branch. Currently we use `master`.
  - Build
    - Add execute shell. We use script below:
    ```bash
    # here we install bundle
    gem install bundler
    # install all dependencies from Gemfile
    bundle install
    # start run
    # Please look https://github.com/qaprosoft/zafira-ruby#possible-environment-and-config-variables
    # for another possible variables
    HEADLESS=true \
    ZAFIRA_ENV_TEST_SUITE_CONFIG_FILE=./test_suite_config.yml \
    ZAFIRA_ENV_CI_RUN_BUILD_NUMBER=${BUILD_NUMBER} \
    ZAFIRA_ENV_CI_JOB_URL=$BUILD_URL \
    ZAFIRA_ENV_CI_HOST=\"$JENKINS_URL\" \
    ZAFIRA_ENV_CI_JOB_NAME=\"$JOB_NAME\" \
    ZAFIRA_ENV_CI_TEST_RUN_UUID=\"$(uuidgen)\" \
    bundle exec cucumber features/ -f pretty -f Zafira::Cucumber::Formatter --out
    ```

### Using usual Jenkins and Zafira instances

First you have to setup your Jenkins.

Following plugins should be installed for proper run:
- Rvm
- Rake Plugin
- chromedriver
- Selenium Capability Axis
- Selenium Plugin
- Xvfb plugin(If you use it)

Please, read how to setup xvfb plugin(If you use it).

Then create a freestyle project.
Following settings should be set before run:
- Source Code Management
  - Git
    - Repository URL. It's a cucumber tests repository. Currently we use `https://github.com/qaprosoft/zafira-ruby-cucumber-integration`.
    - Branch Specifier (blank for 'any'). A branch. Currently we use `master`.
  - Build Environment
    - Start Xvfb before the build, and shut it down after. Should be checked.
    - Run the build in a RVM-managed environment. Should be checked. We use `2.4.0`.
  - Build
    - Add execute shell. We use script below:
    ```bash
    # here we install bundle
    gem install bundler
    # install all dependencies from Gemfile
    bundle install
    # start run
    # Please look https://github.com/qaprosoft/zafira-ruby#possible-environment-and-config-variables
    # for another possible variables
    HEADLESS=true \
    ZAFIRA_ENV_TEST_SUITE_CONFIG_FILE=./test_suite_config.yml \
    ZAFIRA_ENV_CI_RUN_BUILD_NUMBER=${BUILD_NUMBER} \
    ZAFIRA_ENV_CI_JOB_URL=$BUILD_URL \
    ZAFIRA_ENV_CI_HOST=\"$JENKINS_URL\" \
    ZAFIRA_ENV_CI_JOB_NAME=\"$JOB_NAME\" \
    ZAFIRA_ENV_CI_TEST_RUN_UUID=\"$(uuidgen)\" \
    bundle exec cucumber features/ -f pretty -f Zafira::Cucumber::Formatter --out
    ```

Then you can start run :).

## Scenarios

For the example we implemented 3 scenarios.
```cucumber
Feature: Google Searching

Background:
  Given the user opens a browser
  And the user navigates to "https://google.com/"

Scenario: Google shows "Guitar" related links
  When the user enters "Guitar" to the search bar
  Then links related to "Guitar" are shown

Scenario: Google shows "Cat" related links
  When the user enters "Cat" to the search bar
  Then links related to "Dog" are shown
  And links related to "Cat" are shown

Scenario: Google skips search
  When the user enters "Cat" to the search bar
  Then google skips searching
```

1 Scenario should pass, 1 should fail, 1 should be skipped.
If you open Zafira you see following:
![screenshot from 2018-04-08 21-51-42](https://user-images.githubusercontent.com/3288759/38471290-ab67a3b6-3b77-11e8-85ba-2001396b8b6c.png)


## Custom handlers

Note: Here in the example we use custom handler for failed test cases in Zafira.
By default `zafira-ruby` sends failed backtrace only. We wrote the handler that creates a screenshot and sends all scenario's steps. You can find links to artifacts in Zafira on opposite site of a test case name.

You can easily remove it or write your own handlers. Please, read https://github.com/qaprosoft/zafira-ruby#zafira-logging-overrides how to do it. Below is the code of your custom handler and how to enable it in your configuration file:


```ruby
# frozen_string_literal: true

module Cucumber
  class Configuration
    def failed_test_case_handler_class
      FinishedTestCaseHandler
    end
  end
end

class FinishedTestCaseHandler
  def initialize(event)
    self.event = event
  end

  def artifacts
    [screenshot, logs_file]
  end

  private

  attr_accessor :event

  def screenshot
    filename = filename_with_path('.png')
    Browser.window.screenshot.save(filename)

    { name: 'DEMO', link: url_from_filename(filename) }
  end

  def logs_file
    filename = filename_with_path(nil)

    File.open(filename, 'w') do |file|
      file.write("Feature: #{event.test_case.feature.name}\n")
      file.write(build_log_for(event.test_case.feature.background))
      file.write(build_log_for(event.test_case.source[-1]))
      file.write("\n#{event.result.exception.message}\n")
      file.write((event.result.exception.backtrace&.join("\n")).to_s)
    end

    { name: 'LOGS', link: url_from_filename(filename) + "/*view*/" }
  end

  # just ugly methods that makes background
  # and scenario steps and spaces for them
  def build_log_for(steps_set)
    wrapped_steps = ''
    steps_set.children.each do |step|
      wrapped_steps += "    #{step.keyword} #{step.text}\n"
    end

    "  #{steps_set.keyword}: #{steps_set.name}\n" + wrapped_steps
  end

  def filename_with_path(mask)
    dirname = "builds/#{ENV['BUILD_NUMBER']}"
    FileUtils.mkdir_p(dirname) unless File.directory?(dirname)

    "#{dirname}/#{Time.now.to_i}#{mask}"
  end

  def url_from_filename(filename)
    "#{ENV['JOB_URL']}/ws/#{filename}"
  end
end
```
