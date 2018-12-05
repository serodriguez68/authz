$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "authz/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "authz"
  s.version     = Authz::VERSION
  s.authors     = ["Sergio Rodriguez"]
  s.email       = ["se.rodriguez68@gmail.com"]
  s.homepage    = "https://github.com/serodriguez68/authz"
  s.summary     = "An opinionated almost-turnkey solution for managing authorization"
  s.description = "An opinionated almost-turnkey solution for managing authorization"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 5.2.1", ">= 5.2.1.1"
  s.add_dependency 'rails_admin', '~> 1.3'

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "devise"
  s.add_development_dependency "slim-rails"
  s.add_development_dependency "foundation-rails"
  s.add_development_dependency "autoprefixer-rails"
  s.add_development_dependency 'sprockets-es6'
  s.add_development_dependency 'sass-rails'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'factory_bot_rails'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'launchy'
  s.add_development_dependency 'selenium-webdriver'
  s.add_development_dependency 'shoulda-matchers'
  s.add_development_dependency 'faker'
  s.add_development_dependency 'better_errors'
  s.add_development_dependency 'binding_of_caller'
  s.add_development_dependency 'travis'
  s.add_development_dependency 'travis-lint'


end
