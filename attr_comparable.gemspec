require File.expand_path('../lib/attr_comparable/version', __FILE__)

Gem::Specification.new do |gem|
  gem.add_development_dependency 'minitest' # Included in Ruby 1.9, but we want the latest.
  gem.add_development_dependency 'rake', '>=0.9'

  gem.authors       = ["Colin Kelley"]
  gem.email         = ["colindkelley@gmail.com"]
  gem.description   = %q{AttrComparable}
  gem.summary       = %q{Mix-in to make a value class Comparable. Simply declare the order of attributes to compare and the <=> (as needed by Comparable) is generated for you, including support for nil. Includes Comparable.}
  gem.homepage      = "https://github.com/RingRevenue/attr_comparable"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/.*\.rb})
  gem.name          = "attr_comparable"
  gem.version       = AttrComparable::VERSION
end
