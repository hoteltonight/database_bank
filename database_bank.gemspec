# frozen_string_literal: true

require_relative "lib/database_bank/version"

Gem::Specification.new do |gem|
  gem.authors       = ["Christopher Bailey"]
  gem.email         = ["chris@hoteltonight.com"]
  gem.description   = %q{An exchange rate bank for use with the Money gem, where rate data is stored in your database, but sourced externally.}
  gem.summary       = %q{Money gem exchange rate bank using your database.}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "database_bank"
  gem.require_paths = ["lib"]
  gem.version       = DatabaseBank::VERSION

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'

  gem.add_dependency "nokogiri"
  gem.add_dependency "money",    ">= 4.0.2", "<= 7.0"
end
