# frozen_string_literal: true

BeforeAll do
  $api_key = 'abc12312312312312312312312312312'
end

Before('@skip_android') do |_scenario|
  skip_this_scenario('Not compatible with Android') if platform? 'Android'
end

Before('@skip_ios') do |_scenario|
  skip_this_scenario('Not compatible with iOS') if platform? 'iOS'
end

def current_platform
  case Maze.config.farm
  when :bs
    Maze.driver.capabilities['os']
  when :sl, :local
    Maze.driver.capabilities['platformName']
  when :none
    Maze.config.os
  else
    Maze.driver.os
  end
end

def platform?(name)
  # case-insensitive string compare, also accepts symbols. examples:
  #
  # > is_platform? :android
  # > is_platform? 'iOS'
  # > is_platform? 'ios'
  current_platform.casecmp(name.to_s).zero?
end
