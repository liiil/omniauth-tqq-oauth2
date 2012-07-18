# -*- encoding: utf-8 -*-
require File.expand_path('../lib/omniauth-tqq-oauth2/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["cqpx"]
  gem.email         = ["cqpanxu@gmail.com"]
  gem.description   = %q{OmniAuth Oauth2 strategy for t.qq.com.}
  gem.summary       = %q{OmniAuth Oauth2 strategy for t.qq.com.}
  gem.homepage      = "https://github.com/cqpx/omniauth-tqq-oauth2"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "omniauth-tqq-oauth2"
  gem.require_paths = ["lib"]
  gem.version       = Omniauth::Tqq::Oauth2::VERSION

  gem.add_dependency 'omniauth', '~> 1.0'
  gem.add_dependency 'omniauth-oauth2', '~> 1.0'
end
