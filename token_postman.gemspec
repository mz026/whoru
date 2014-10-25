$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "token_postman/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "token_postman"
  s.version     = TokenPostman::VERSION
  s.authors     = ["TODO: Your name"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of TokenPostman."
  s.description = "TODO: Description of TokenPostman."

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 4.0.10"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
end
