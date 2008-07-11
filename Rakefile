#!/usr/bin/env ruby

Gem::manage_gems
require 'rake/rdoctask'
require "rake/testtask"
require 'rake/gempackagetask'

begin
  require "rubygems"
rescue LoadError
  nil
end

RUBYPOKER_VERSION = "0.3.0"

task :default => [:test]

spec = Gem::Specification::new do |s|
  s.name = "ruby-poker"
  s.summary = "Ruby library for comparing poker hands and determining the winner." 
  s.version = RUBYPOKER_VERSION
  
  s.rubyforge_project = "rubypoker"
  s.platform = Gem::Platform::RUBY
  
  s.files =  Dir.glob("{examples,lib,test}/**/**/*") + ["Rakefile"]
  s.require_path = "lib" 

  s.has_rdoc = true 
  s.extra_rdoc_files = ["README", "CHANGELOG", "LICENSE"]
  s.rdoc_options << '--title' << 'Ruby Poker Documentation' <<
                    '--main'  << 'README.rdoc' <<
                    '--inline-source' << '-q'
  
  s.test_files = Dir.glob("test/*.rb")

  s.author = "Robert Olson"
  s.email = "rko618@gmail.com"
  s.homepage = "http://github.com/robolson/ruby-poker"
end

Rake::GemPackageTask.new(spec) do |pkg| 
  pkg.need_tar = true 
  pkg.need_zip = true
end

Rake::TestTask.new do |test|
  test.libs << "test"
  test.test_files = Dir[ "test/test_*.rb" ]
  test.verbose = true
end

desc "Start autotest"
task :autotest do
  ruby "-I lib -w /usr/bin/autotest"
end

Rake::RDocTask.new(:docs) do |rdoc|
  rdoc.rdoc_files.include('README.rdoc', 'CHANGELOG', 'LICENSE', 'lib/')
  rdoc.main     = 'README.rdoc'
  rdoc.rdoc_dir = 'doc/html'
  rdoc.title    = 'Ruby Poker Documentation'
  rdoc.options << '--inline-source'
end