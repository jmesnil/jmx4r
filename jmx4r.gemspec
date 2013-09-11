# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jmx4r/version'

Gem::Specification.new do |spec|
  spec.name     = "jmx4r"
  spec.version  = JMX::VERSION
  spec.platform = Gem::Platform::RUBY
  spec.summary  = "jmx4r is a JMX library for JRuby"
  spec.files    = Dir.glob("{examples,lib,test}/**/*.rb") + ["Rakefile"]

  spec.test_files       =  "test/ts_all.rb"
  spec.has_rdoc         =  true
  spec.extra_rdoc_files =  %w{README.rdoc LICENSE.txt}
  spec.rdoc_options     << '--title' << 'jmx4r Documentation' <<
                           '--main'  << 'README.rdoc'

  spec.require_path  = 'lib'

  spec.authors       = ["Jeff Mesnil", "R. Tyler Croy"]
  spec.email         = ["jmesnil@gmail.com", "tyler@monkeypox.org"]
  spec.homepage      = "http://github.com/jmesnil/jmx4r"
  spec.description   = <<END_DESC
jmx4r is a JMX library for JRuby
END_DESC
end
