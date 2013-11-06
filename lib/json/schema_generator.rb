module JSON
  class SchemaGenerator
    class << self
      def generate name, data, version
        generator = JSON::SchemaGenerator.new name, version
        generator.generate data
      end
    end

    def initialize name, version = 'draft3'
      @buffer = StringIO.new
      @name = name
      @version = 'draft-03' if version == 'draft3'
      @version = 'draft-04' if version == 'draft4'
    end

    def generate raw_data
      # Write header
      @buffer.puts "{"
      @buffer.puts "\"$schema\": \"http://json-schema.org/#{@version}/schema#\","
      @buffer.print '"description": "Generated from '
      @buffer.print @name
      @buffer.print " with shasum "
      @buffer.print Digest::SHA1.hexdigest raw_data
      @buffer.puts '",'

      # 
      data = JSON.load(raw_data)

      @buffer.puts create_hash(data, nil)
      close
      result
    end

    protected

    def close
      @buffer.puts "}"
    end

    def create_values(key, value, required_keys = nil)
      if required_keys.nil?
        required = true
      else
        required = required_keys.include? key
      end

      buffer = StringIO.new
      buffer.puts "\"#{key}\": {"
      case value
      when NilClass
      when TrueClass, FalseClass
        buffer.puts '"type": "boolean",'
        buffer.puts "\"required\": #{required}"

      when String
        buffer.puts '"type": "string",'
        buffer.puts "\"required\": #{required}"

      when Integer
        buffer.puts '"type": "integer",'
        buffer.puts "\"required\": #{required}"

      when Float
        buffer.puts '"type": "number",'
        buffer.puts "\"required\": #{required}"
      when Array
        buffer << create_array(value, detect_required(value))
      when Hash
        buffer << create_hash(value, required_keys)
      else
        raise "Unknown Type for #{key}! #{value.class}"
      end
      buffer.print "}"
      buffer.string
    end

    def create_hash(data, required_keys)
      buffer = StringIO.new
      buffer.puts '"type": "object",'
      buffer.puts '"required": true,'
      buffer.puts '"properties": {'
      items = data.collect do |k,v|
        create_values k, v, required_keys
      end
      buffer << items.join(",\n")
      buffer.puts '}'

      buffer.string
    end

    def create_array(data, required_keys)
      buffer = StringIO.new
      buffer.puts '"type": "array",'
      buffer.puts '"required": true,'
      if data.size == 0
        buffer.puts '"minItems": 0,'
      else
        buffer.puts '"minItems": 1,'
      end
      buffer.puts '"uniqueItems": true,'
      buffer.puts create_values("items", data.first, required_keys)

      buffer.string
    end

    def detect_required(collection)
      begin
        required_keys = collection.map(&:keys).inject{|required,keys| required & keys }
      rescue
        required_keys = nil
      end
      required_keys
    end

    def result
      @buffer.string
    end
  end
end
