require 'shoulda-matchers'
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    # Choose a test framework:
    with.test_framework :rspec
    # Choose matchers to include
    with.library :rails
  end
end