require "bundler/gem_tasks"

task :default => :test

task :test do
  ENV['PATH'] = ENV['PATH'] + File::PATH_SEPARATOR + File.expand_path('bin', Dir.pwd)
  puts ENV['PATH']
  Bundler.with_clean_env do
    Dir.chdir 'kata' do
      system 'bundle install'
      system 'bundle exec rake'
    end
  end
  fail 'Tests did not pass!' unless $?.success?
end
