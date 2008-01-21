#!/usr/bin/env ruby

require "rubygems"
Gem::manage_gems
require "rake/gempackagetask"

spec = Gem::Specification::new do |s|
  s.name = "ruby-poker"
  s.summary = "Ruby library for determining the winner in a game of poker." 
  s.version = "0.2.0" 
  
  s.rubyforge_project = "rubypoker"
  s.platform = Gem::Platform::RUBY 
  
  s.files = FileList["{examples,lib,test}/**/*"]
  s.require_path = "lib" 

  s.has_rdoc = true 
  s.extra_rdoc_files = ["README", "CHANGELOG", "LICENSE"]
  
  s.test_files = Dir.glob("test/*.rb")

  s.author = "Robert Olson"
  s.email = "rko618@gmail.com"
  s.homepage = "http://rubyforge.org/projects/rubypoker/"
end

Rake::GemPackageTask.new(spec) do |pkg| 
  pkg.need_tar = true 
end

desc "Generate a new gem"
task :default => "pkg/#{spec.name}-#{spec.version}.gem" do
  putsCheck = `grep puts lib/*`
  if putsCheck.size > 0
   puts "********** WARNING: stray puts left in code"
  end
  puts "generated latest version"
end

desc "Run the ruby-poker test suite"
task :test do 
  Dir['test/**/test_*.rb'].all? do |file|
    system("ruby -Ilib #{file}")
  end or raise "Failures"
end

task :autotest do
  ruby "-I lib -w ./bin/autotest"
end

task :zentest do
  `zentest card.rb test_card.rb > test_card_2.rb`
  `zentest ruby-poker.rb test_poker_hand.rb > test_poker_hand_2.rb`
end

task :docs do
  `rm -rf doc`
  `rdoc --line-numbers -U README CHANGELOG LICENSE lib/card.rb lib/ruby-poker.rb`
end