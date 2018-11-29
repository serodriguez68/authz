$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "opinionated_pundit/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "opinionated_pundit"
  s.version     = OpinionatedPundit::VERSION
  s.authors     = ["Sergio Rodriguez"]
  s.email       = ["se.rodriguez68@gmail.com"]
  s.homepage    = "https://github.com/serodriguez68/opinionated-pundit"
  s.summary     = "An opinionated and user configurable way of managing your authorization logic using pundit."
  s.description = "An opinionated and user configurable way of managing your authorization logic using pundit."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 5.2.1", ">= 5.2.1.1"
  s.add_dependency "pundit"

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

end
