$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "sable/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "sable"
  s.version     = Sable::VERSION
  s.authors     = ["RJ Zaworski"]
  s.email       = ["rj@rjzaworski.com"]
  s.homepage    = "http://github.com/rjz/sable"
  s.summary     = "Concerns for kick-starting transactional Rails apps"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.1.3"

  s.add_development_dependency "sqlite3"
end
