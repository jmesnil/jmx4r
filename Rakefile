require "rubygems"
require "rdoc/task"
require "rake/testtask"
require 'bundler/gem_tasks'

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

desc "Show library's code statistics"
task :stats do
  require 'code_statistics'
  CodeStatistics.new( ["jmx4r", "lib"], 
                      ["Examples", "examples"], 
                      ["Units", "test"] ).to_s
end
