source 'https://rubygems.org'

# A reference to Maze Runner is only needed for running tests locally and if committed it must be
# portable for CI, e.g. a specific release.  However, leaving it commented out would mean quicker CI.
gem 'bugsnag-maze-runner', '~> 9.0'
gem 'cocoapods'

# Use a specific branch
#gem 'bugsnag-maze-runner', git: 'https://github.com/bugsnag/maze-runner', branch: 'master'

# Locally, you can run against Maze Runner branches and uncommitted changes:
#gem 'bugsnag-maze-runner', path: '../maze-runner'

# Only install bumpsnag if we're using Github actions
unless ENV['GITHUB_ACTIONS'].nil?
  gem 'bumpsnag', git: 'https://github.com/bugsnag/platforms-bumpsnag', branch: 'main'
end
