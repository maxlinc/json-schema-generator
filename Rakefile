require "bundler/gem_tasks"

task :default => :test

task :test do
  ENV['PATH'] = ENV['PATH'] + File::PATH_SEPARATOR + File.expand_path('bin', Dir.pwd)
  puts ENV['PATH']
  system 'cd tests && bundle exec rake'
  fail 'Tests did not pass!' unless $?.success?
end
