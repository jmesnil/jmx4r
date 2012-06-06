require "rake/testtask"
require "rake/rdoctask"
require "rake/gempackagetask"

require "rubygems"

dir     = File.dirname(__FILE__)
lib     = File.join(dir, "lib", "jmx4r.rb")
version = "0.1.4"

task :default => [:test]

Rake::TestTask.new do |test|
  test.libs       << "test"
  test.test_files =  ["test/ts_all.rb"]
  test.verbose    = false 
end

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_files.include( "README.rdoc", "LICENSE.txt", "AUTHORS.txt", 
                           "lib/" )
  rdoc.main     = "README.rdoc"
  rdoc.rdoc_dir = "doc/html"
  rdoc.title    = "jmx4r Documentation"
  rdoc.options << "-S"
end

desc "Publish current documentation to Rubyforge"
task :publish_docs => [:rdoc] do
  sh "scp -r doc/html/* " +
     "jmesnil@rubyforge.org:/var/www/gforge-projects/jmx4r/doc/"
end

spec = Gem::Specification.new do |spec|
  spec.name     = "jmx4r"
  spec.version  = version 
  spec.platform = Gem::Platform::RUBY
  spec.summary  = "jmx4r is a JMX library for JRuby"
  spec.files    = Dir.glob("{examples,lib,test}/**/*.rb") + ["Rakefile"]

  spec.test_files       =  "test/ts_all.rb"
  spec.has_rdoc         =  true
  spec.extra_rdoc_files =  %w{README.rdoc LICENSE.txt}
  spec.rdoc_options     << '--title' << 'jmx4r Documentation' <<
                           '--main'  << 'README.rdoc'

  spec.require_path      = 'lib'

  spec.author            = "Jeff Mesnil"
  spec.email             = "jmesnil@gmail.com"
  spec.rubyforge_project = "jmx4r"
  spec.homepage          = "http://jmesnil.net/wiki/Jmx4r"
  spec.description       = <<END_DESC
jmx4r is a JMX library for JRuby
END_DESC
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end

desc "Show library's code statistics"
task :stats do
  require 'code_statistics'
  CodeStatistics.new( ["jmx4r", "lib"], 
                      ["Examples", "examples"], 
                      ["Units", "test"] ).to_s
end
