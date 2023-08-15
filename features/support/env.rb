# frozen_string_literal: true

BeforeAll do
  $api_key = 'abc12312312312312312312312312312'
end

Before('@skip_android') do |_scenario|
  skip_this_scenario('Not compatible with Android') if Maze::Helper.get_current_platform == 'android'
end

Before('@skip_ios') do |_scenario|
  skip_this_scenario('Not compatible with iOS') if Maze::Helper.get_current_platform == 'ios'
end
