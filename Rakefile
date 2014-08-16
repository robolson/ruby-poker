require 'rake/testtask'
Rake::TestTask.new do |t|
  t.libs = ['lib']
  t.verbose = true
  t.warning = true
  t.test_files = FileList['test/test_card.rb', 'test/test_poker_hand.rb', 'test/test_full_house.rb']
end

task :default => :test
