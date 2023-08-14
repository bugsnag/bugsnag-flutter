# frozen_string_literal: true

When('I run {string}') do |scenario_name|
  execute_command :run_scenario, scenario_name
end

When("I run {string} and relaunch the crashed app") do |event_type|
  step("I run \"#{event_type}\"")
  step('I relaunch the app after a crash')
end

When('I configure Bugsnag for {string}') do |scenario_name|
  execute_command :start_bugsnag, scenario_name
end

When('I configure the app to run in the {string} state') do |extra_config|
  $extra_config = extra_config
end

def execute_command(action, scenario_name)
  extra_config = $extra_config || ''
  command = { action: action, scenario_name: scenario_name, extra_config: extra_config }
  Maze::Server.commands.add command
  
  touch_action = Appium::TouchAction.new
  touch_action.tap({:x => 200, :y => 200})
  touch_action.perform

  $extra_config = ''
  # Ensure fixture has read the command
  count = 100
  sleep 0.1 until Maze::Server.commands.remaining.empty? || (count -= 1) < 1
  raise 'Test fixture did not GET /command' unless Maze::Server.commands.remaining.empty?
end

When('I relaunch the app') do
  Maze.driver.launch_app
end

When("I relaunch the app after a crash") do
  # Wait for the app to stop running before relaunching
  step 'the app is not running'
  Maze.driver.launch_app
end

Then('the app is not running') do
  Maze::Wait.new(interval: 1, timeout: 20).until do
    Maze.driver.app_state('com.bugsnag.flutter.test.app') == :not_running
  end
end

Then(/^on (Android|iOS), (.+)/) do |platform, step_text|
  current_platform = Maze::Helper.get_current_platform
  step(step_text) if current_platform.casecmp(platform).zero?
end
