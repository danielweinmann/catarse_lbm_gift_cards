$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "catarse_lbm_gift_cards/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "catarse_lbm_gift_cards"
  s.version     = CatarseLbmGiftCards::VERSION
  s.authors     = ["Daniel Weinmann"]
  s.email       = ["danielweinmann@gmail.com"]
  s.homepage    = "https://github.com/danielweinmann/catarse_lbm_gift_cards"
  s.summary     = "Catarse payment engine for LittleBigMoney Gift Cards"
  s.description = "Catarse payment engine for LittleBigMoney Gift Cards"

  s.files         = `git ls-files`.split($\)
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})

  s.add_dependency "rails", "~> 3.2.6"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "fakeweb"
  s.add_development_dependency "factory_girl_rails"
  s.add_development_dependency "database_cleaner"
end
