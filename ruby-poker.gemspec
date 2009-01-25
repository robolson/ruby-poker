Gem::Specification.new do |s|
  s.name     = "ruby-poker"
  s.version  = "0.3.1"
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
		"lib/card.rb", 
		"lib/ruby-poker.rb", 
		"LICENSE", 
		"Rakefile", 
		"README.rdoc", 
		"ruby-poker.gemspec"]
  s.test_files = ["test/test_card.rb", 
    "test/test_poker_hand.rb"]
  s.require_paths << 'lib'
  
  s.extra_rdoc_files = ["README", "CHANGELOG", "LICENSE"]
  s.rdoc_options << '--title' << 'Ruby Poker Documentation' <<
                    '--main'  << 'README.rdoc' <<
                    '--inline-source' << '-q'
  
  # s.add_dependency("thoughtbot-shoulda", ["> 2.0.0"])
end
