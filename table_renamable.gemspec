$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "table_renamable/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "table_renamable"
  s.version     = TableRenamable::VERSION
  s.authors     = ["Dan Langevin"]
  s.email       = ["dan.langevin@lifebooker.com"]
  s.homepage    = "http://github.com/LifebookerInc/table_renamable"
  s.summary     = "Renaming tables and columns"
  s.description = "Gem to support live renaming of tables columns"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 2.3.17"
  s.add_dependency 'mysql2', "< 0.3"
  # s.add_dependency "jquery-rails"
end
