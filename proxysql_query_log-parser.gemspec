
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "proxysql_query_log/parser/version"

Gem::Specification.new do |spec|
  spec.name          = "proxysql_query_log-parser"
  spec.version       = ProxysqlQueryLog::Parser::VERSION
  spec.authors       = ["r_takaishi"]
  spec.email         = ["ryo.takaishi.0@gmail.com"]

  spec.summary       = 'ProxySQL query log parser library'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/takaishi/proxysql_query_log-parser'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "test-unit", "~> 3.0"
  spec.add_development_dependency "rubocop"
end
