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

CHALLENGE_OPTS = {
  'generate_defaults' => '--schema-version draft4 --defaults',
  'generate_draft3'   => '--schema-version draft3',
  'generate_draft4'   => ''
}

task :challenge do
  challenge = ENV['CHALLENGE']
  challenge_file = ENV['SAMPLE_FILE']
  fail "Cannot run outside framwork... yet" unless challenge and challenge_file

  sh "bundle exec json-schema-generator #{challenge_file} #{CHALLENGE_OPTS[challenge]} | tee tmp/test_output"
end
