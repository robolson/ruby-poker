require 'rubygems'

spec = Gem::Specification::new do |s|
  s.name = "ruby-poker"
  s.version = "0.1.1" 
  s.platform = Gem::Platform::RUBY
  s.summary = "Ruby library for determining the winner in a game of poker."

  cadidates = Dir.glob("{docs,examples,lib,test}/**/*")
  s.files = candidates.delete_if do |item|
    item.include?("svn")
  end
  
  s.require_path = "lib" 
  s.autorequire = "poker_hand"

  s.has_rdoc = File::exist? "docs" 
  s.extra_rdoc_files = ["README", "CHANGELOG", "LICENSE"]
  s.test_file = "test/ts_rubypoker.rb" if File::directory? "test"

  s.author = "Robert Olson"
  s.email = "rko618@gmail.com"
  s.homepage = "http://rubyforge.org/projects/rubypoker/"
end
