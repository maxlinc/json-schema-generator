require 'json/schema_generator/statement_group'
require 'json/schema_generator/brute_force_required_search'

module JSON
  class SchemaGenerator
    DRAFT3 = 'draft-03'
    DRAFT4 = 'draft-04'
    DEFAULT_VERSION = 'draft4'
    SUPPORTED_VERSIONS = ['draft3', 'draft4']

    class << self
      def generate name, data, opts = {}
        JSON::SchemaGenerator.new(name, opts).generate data
      end
    end

    def initialize name, opts = {}
      version = opts[:schema_version] || DEFAULT_VERSION
      # Unfortunately json-schema.org and json-schema (gem) use different version strings
      if ['draft3', 'draft-03'].include? version.to_s.downcase
        @version = DRAFT3
      elsif ['draft4', 'draft-04'].include? version.to_s.downcase
        @version = DRAFT4
      else
        abort "Unsupported schema version: #{version}"
      end

      @defaults = opts[:defaults]

      @buffer = StringIO.new
      @name = name
    end

    def generate raw_data
      data = JSON.load(raw_data)
      @brute_search = BruteForceRequiredSearch.new data

      statement_group = StatementGroup.new
      statement_group.add "\"$schema\": \"http://json-schema.org/#{@version}/schema#\""
      statement_group.add "\"description\": \"Generated from #{@name} with shasum #{Digest::SHA1.hexdigest raw_data}\""
      case data
      when Array
        $stop = true
        create_array(statement_group, data, detect_required(data))
      else
        create_hash(statement_group, data, detect_required(data))
      end
      @buffer.puts statement_group
      result
    end

    protected

    def create_primitive(statement_group, key, value, required_keys)
      if required_keys.nil?
        required = true
      else
        required = required_keys.include? key
      end

      type = case value
      when TrueClass, FalseClass
        "boolean"
      when String
        "string"
      when Integer
        "integer"
      when Float
        "number"
      else
        raise "Unknown Primitive Type for #{key}! #{value.class}"
      end

      statement_group.add "\"oneOf\": [{\"type\": \"#{type}\"}, {\"type\": \"null\"}]"
      statement_group.add "\"required\": #{required}" if @version == DRAFT3
      statement_group.add "\"default\": #{value.inspect}" if @defaults
    end

    def create_values(key, value, required_keys = nil, in_array = false)
      statement_group = StatementGroup.new key
      case value
      when NilClass
      when TrueClass, FalseClass, String, Integer, Float
        create_primitive(statement_group, key, value, required_keys)
      when Array
        create_array(statement_group, value, detect_required(value))
      when Hash
        if in_array
          create_hash(statement_group, value, required_keys)
        else
          create_hash(statement_group, value, detect_required(value))
        end
      else
        raise "Unknown Type for #{key}! #{value.class}"
      end
      statement_group
    end

    def create_hash(statement_group, data, required_keys)
      statement_group.add '"type": "object"'
      statement_group.add '"required": true' if @version == DRAFT3
      if @version == DRAFT4
        required_keys ||= []
        required_string = required_keys.map(&:inspect).join ', '
        statement_group.add "\"required\": [#{required_string}]" unless required_keys.empty?
      end
      statement_group.add create_hash_properties data, required_keys
      statement_group
    end

    def create_hash_properties(data, required_keys)
      statement_group = StatementGroup.new "properties"
      data.collect do |k,v|
        @brute_search.push k,v
        statement_group.add create_values k, v, required_keys
        @brute_search.pop
      end
      statement_group
    end

    def create_array(statement_group, data, required_keys)
      statement_group.add '"type": "array"'
      statement_group.add '"required": true' if @version == DRAFT3
      # FIXME - Code assumes that all items in the array have the same structure
      # Assume lowest common denominator - allow 0 items and unique not required
      statement_group.add '"minItems": 0'

      # TODO - consider a eq? method for StatementGroup class to evaluate LCD schema from all items in array
      statement_group.add create_values("items", data.first, required_keys, true)

      statement_group
    end

    def detect_required(collection)
      @brute_search.find_required
    rescue NoMethodError
      collection.keys if collection.respond_to?(:keys)
    end

    def result
      @buffer.string
    end
  end
end
