require 'rake/testtask'
Rake::TestTask.new do |t|
  t.libs = ['lib']
  t.verbose = true
  t.warning = true
  t.test_files = FileList['test/test_card.rb', 'test/test_poker_hand.rb', 'test/test_full_house.rb']
end

Rake::TestTask.new do |t|
  t.libs = ['lib']
  t.name = 'test:integration'
  t.verbose = true
  t.warning = true
  t.test_files = FileList['test/integration/test_a_million_hands.rb']
end

task :default => :test
