require File.expand_path('../lib/attr_comparable/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Colin Kelley"]
  gem.email         = ["colindkelley@gmail.com"]
  gem.description   = %q{AttrComparable}
  gem.summary       = %q{Mix-in to make a value class Comparable. Simply declare the order of attributes to compare and the <=> (as needed by Comparable) is generated for you, including support for nil. Includes Comparable.}
  gem.homepage      = "https://github.com/RingRevenue/attr_comparable"

  gem.metadata = {
    'allowed_push_host' => 'https://rubygems.org'
  }

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/.*\.rb})
  gem.name          = "attr_comparable"
  gem.version       = AttrComparable::VERSION
end
