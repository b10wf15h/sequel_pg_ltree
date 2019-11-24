
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sequel/plugins/pg_ltree/version'

Gem::Specification.new do |spec|
  spec.name          = "sequel_pg_ltree"
  spec.version       = SequelPgLtree::VERSION
  spec.authors       = ["Igor Milisav"]
  spec.email         = ["igor.milisav@gmail.com"]

  spec.summary       = 'PostgreSQL LTree helper with sequel ORM'
  spec.description   = 'PostgreSQL LTree helper with sequel ORM'
  spec.homepage      = 'https://github.com/b10wf15h/sequel_pg_ltree'
  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ['lib']


  spec.add_dependency 'sequel', '>= 5.22.0'
  spec.add_dependency 'pg', '>= 0.17.0', '< 2'


  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'minitest'
end
