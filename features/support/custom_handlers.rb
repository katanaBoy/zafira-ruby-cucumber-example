# frozen_string_literal: true

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
