$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "whoru/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "whoru"
  s.version     = Whoru::VERSION
  s.authors     = ["Yang-Hsing Lin"]
  s.email       = ["yanghsing.lin@gmail.com"]
  s.homepage    = "https://github.com/mz026/whoru"
  s.summary     = "A rails plugin handling login stuff in controller"
  s.description = "A rails plugin handling login stuff in controller"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 4.0.10"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
end
