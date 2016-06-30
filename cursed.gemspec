# coding: utf-8
# frozen_string_literal: true
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cursed/version'

Gem::Specification.new do |spec|
  spec.name          = 'cursed'
  spec.version       = Cursed::VERSION
  spec.licenses      = ['MIT']
  spec.authors       = ['Will Howard']
  spec.email         = ['will@influitive.com']
  spec.homepage      = 'https://www.github.com/influitive/cursed'

  spec.summary       = 'PostgreSQL based cursoring in ActiveRecord and Sequel'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ['lib']
end
