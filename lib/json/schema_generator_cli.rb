class JSON::SchemaGeneratorCLI
  def initialize(argv, stdin=STDIN, stdout=STDOUT, stderr=STDERR, kernel=Kernel)
    @argv, @stdin, @stdout, @stderr, @kernel = argv, stdin, stdout, stderr, kernel
  end

  def execute!
    file = ARGV.shift
    version = ARGV.shift || 'draft3'
    schema = JSON.parse(JSON::SchemaGenerator.generate file, File.read(file), version)
    @stdout.puts JSON.pretty_generate schema
    @kernel.exit(0)
  end
end