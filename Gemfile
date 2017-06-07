# Declare your gem's dependencies in manageiq-providers-foreman.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

gem "foreman_api_client", ">=0.1.0", :require => false, :git => "https://github.com/ManageIQ/foreman_api_client.git", :branch => "master"

# Load Gemfile with dependencies from manageiq
eval_gemfile(File.expand_path("spec/manageiq/Gemfile", __dir__))
