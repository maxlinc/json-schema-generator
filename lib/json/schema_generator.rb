require 'json/schema_generator/statement_group'

module JSON
  class SchemaGenerator
    DRAFT3 = 'draft-03'
    DRAFT4 = 'draft-04'

    class << self
      def generate name, data, version
        generator = JSON::SchemaGenerator.new name, version
        generator.generate data
      end
    end

    def initialize name, version = 'draft3'
      @buffer = StringIO.new
      @name = name
      @version = DRAFT3 if version == 'draft3'
      @version = DRAFT4 if version == 'draft4'
    end

    def generate raw_data
      data = JSON.load(raw_data)
      # Write header
      statement_group = StatementGroup.new
      statement_group.add "\"$schema\": \"http://json-schema.org/#{@version}/schema#\""
      statement_group.add "\"description\": \"Generated from #{@name} with shasum #{Digest::SHA1.hexdigest raw_data}\""
      create_hash(statement_group, data, detect_required(data))
      # statement_group.add '"type": "object"'
      # statement_group.add '"required": true' if @version == DRAFT3
      # statement_group.add create_hash_properties(data, detect_required(data))
      @buffer.puts statement_group
      result
    end

    protected

    def create_values(key, value, required_keys = nil)
      if required_keys.nil?
        required = true
      else
        required = required_keys.include? key
      end

      statement_group = StatementGroup.new key
      # buffer.puts "\"#{key}\": {"
      case value
      when NilClass
      when TrueClass, FalseClass
        statement_group.add '"type": "boolean"'
        statement_group.add "\"required\": #{required}" if @version == DRAFT3

      when String
        statement_group.add '"type": "string"'
        statement_group.add "\"required\": #{required}" if @version == DRAFT3

      when Integer
        statement_group.add '"type": "integer"'
        statement_group.add "\"required\": #{required}" if @version == DRAFT3

      when Float
        statement_group.add '"type": "number"'
        statement_group.add "\"required\": #{required}" if @version == DRAFT3
      when Array
        create_array(statement_group, value, detect_required(value))
      when Hash
        create_hash(statement_group, value, detect_required(value))
      else
        raise "Unknown Type for #{key}! #{value.class}"
      end
      statement_group
    end

    def create_hash(statement_group, data, required_keys)
      # statement_group = StatementGroup.new
      statement_group.add '"type": "object"'
      statement_group.add '"required": true' if @version == DRAFT3
      if @version == DRAFT4
        required_keys ||= []
        required_string = required_keys.map(&:inspect).join ', '
        statement_group.add "\"required\": [#{required_string}]"
      end
      statement_group.add create_hash_properties data, required_keys
      statement_group
    end

    def create_hash_properties(data, required_keys)
      statement_group = StatementGroup.new "properties"
      data.collect do |k,v|
        statement_group.add create_values k, v, required_keys
      end
      statement_group
    end

    def create_array(statement_group, data, required_keys)
      # statement_group = StatementGroup.new
      statement_group.add '"type": "array"'
      statement_group.add '"required": true' if @version == DRAFT3
      if data.size == 0
        statement_group.add '"minItems": 0'
      else
        statement_group.add '"minItems": 1'
      end
      statement_group.add '"uniqueItems": true'
      statement_group.add create_values("items", data.first, required_keys)

      statement_group
    end

    def detect_required(collection)
      begin
        required_keys = collection.map(&:keys).inject{|required,keys| required & keys }
      rescue
        if collection.respond_to? :keys
          required_keys = collection.keys
        else
          required_keys = nil
        end
      end
      required_keys
    end

    def result
      @buffer.string
    end
  end
end
