$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "catarse_payulatam/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "catarse_payulatam"
  s.version     = CatarsePayulatam::VERSION
  s.authors     = ["Gustavo Guichard", "Daniel Weinmann"]
  s.email       = ["gustavoguichard@gmail.com", "danielweinmann@gmail.com"]
  s.homepage    = "https://github.com/danielweinmann/catarse_payulatam"
  s.summary     = "PayU Latam integration with Catarse"
  s.description = "PayU Latam integration with Catarse crowdfunding platform"

  s.files         = `git ls-files`.split($\)
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})

  s.add_dependency "rails", "~> 3.2.6"
  s.add_dependency "payulatam"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "fakeweb"
  s.add_development_dependency "factory_girl_rails"
  s.add_development_dependency "database_cleaner"
end
