# encoding: UTF-8
lib = File.expand_path('../lib/', __FILE__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

require 'spree_vetfort/version'

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_vetfort'
  s.version     = SpreeVetfort.version
  s.summary     = 'Add extension summary here'
  s.description = 'Add (optional) extension description here'
  s.required_ruby_version = '>= 3.2'

  s.author    = 'You'
  s.email     = 'you@example.com'
  s.homepage  = 'https://github.com/your-github-handle/spree_vetfort'
  s.license = 'BSD-3-Clause'

  s.files       = `git ls-files`.split("\n").reject { |f| f.match(/^spec/) && !f.match(/^spec\/fixtures/) }
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree'
  s.add_dependency 'spree_extension'

  s.add_dependency 'dry-validation'
  s.add_dependency 'dry-monads'
  s.add_dependency 'dry-struct'
  s.add_dependency 'dry-system'
  s.add_dependency 'rainbow'
  s.add_dependency 'httparty'

  s.add_development_dependency 'spree_dev_tools'
end
