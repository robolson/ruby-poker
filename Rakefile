require 'rubygems'
require 'rake'

begin
  require 'metric_fu'
rescue LoadError
end

RUBYPOKER_VERSION = "0.3.1"

spec = Gem::Specification.new do |s|
  s.name     = "ruby-poker"
  s.version  = RUBYPOKER_VERSION
  s.date     = "2009-01-24"
  s.rubyforge_project = "rubypoker"
  s.platform = Gem::Platform::RUBY
  s.summary = "Poker library in Ruby"
  s.description = "Ruby library for comparing poker hands and determining the winner."
  s.author  = "Rob Olson"
  s.email    = "rko618@gmail.com"
  s.homepage = "http://github.com/robolson/ruby-poker"
  s.has_rdoc = true
  s.files    = ["CHANGELOG", 
                "examples/deck.rb", 
                "examples/quick_example.rb", 
                "lib/ruby-poker.rb",
                "lib/ruby-poker/card.rb", 
                "lib/ruby-poker/poker_hand.rb", 
                "LICENSE", 
                "Rakefile", 
                "README.rdoc", 
                "ruby-poker.gemspec"]
  s.test_files = ["test/test_helper.rb", "test/test_card.rb", "test/test_poker_hand.rb"]
  s.require_paths << 'lib'

  s.extra_rdoc_files = ["README.rdoc", "CHANGELOG", "LICENSE"]
  s.rdoc_options << '--title' << 'Ruby Poker Documentation' <<
                    '--main'  << 'README.rdoc' <<
                    '--inline-source' << '-q'

  # s.add_dependency("thoughtbot-shoulda", ["> 2.0.0"])
end

require 'rake/gempackagetask'
Rake::GemPackageTask.new(spec) do |pkg| 
  pkg.need_tar = true 
  pkg.need_zip = true
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.verbose = true
  test.warning = true
end

desc "Start autotest"
task :autotest do
  ruby "-I lib -w /usr/bin/autotest"
end

require 'rake/rdoctask'
Rake::RDocTask.new(:docs) do |rdoc|
  rdoc.main     = 'README.rdoc'
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = "Ruby Poker #{RUBYPOKER_VERSION}"
  rdoc.rdoc_files.include('README.rdoc', 'CHANGELOG', 'LICENSE', 'lib/**/*.rb')
end

task :default => :test