#!/usr/bin/env ruby

require 'optparse'

class JSON::SchemaGeneratorCLI
  def initialize(argv, stdin=STDIN, stdout=STDOUT, stderr=STDERR, kernel=Kernel)
    @argv, @stdin, @stdout, @stderr, @kernel = argv, stdin, stdout, stderr, kernel
  end

  def execute!
    default_version = JSON::SchemaGenerator::DEFAULT_VERSION
    supported_versions = JSON::SchemaGenerator::SUPPORTED_VERSIONS

    options = {
      :schema_version => default_version,
      :defaults => false
    }



    OptionParser.new do |opts|
      opts.on("--defaults", "Record default values in the generated schema") { options[:defaults] = true }
      opts.on("--schema-version [VERSION]", [:draft3, :draft4],
        "Version of json-schema to generate (#{supported_versions.join ', '}).  Default: #{default_version}") do |schema_version|
          options[:schema_version] = schema_version
        end
      opts.parse!
    end

    file = ARGV.shift
    schema = JSON.parse(JSON::SchemaGenerator.generate file, File.read(file), options)
    @stdout.puts JSON.pretty_generate schema
    @kernel.exit(0)
  end
end