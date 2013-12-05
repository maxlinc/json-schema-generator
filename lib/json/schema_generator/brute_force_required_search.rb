require 'jsonpath'

module JSON
  class SchemaGenerator
    class BruteForceRequiredSearch
      def initialize(data)
        @data = data.dup
        if data.is_a? Array
          @json_path = ['$[*]']
        else
          @json_path = ['$']
        end
      end

      def push(key, value)
        if value.is_a? Array
          @json_path.push "#{key}[*]"
        else
          @json_path.push key
        end
      end

      def pop
        @json_path.pop
      end

      def current_path
        @json_path.join '.'
      end

      def search_path search_key
        current_path.gsub(/\[\*\]$/, "[?(@.#{search_key})]")
      end

      def required? child_key
        begin
          JsonPath.new(search_path(child_key)).on(@data).count == JsonPath.new(current_path).on(@data).count
        rescue SyntaxError
          # There are some special characters that can't be handled by JsonPath.
          # e.g. if child key is OS-DCF:diskConfig
          false
        end
      end

      def child_keys 
        JsonPath.new(current_path).on(@data).map(&:keys).flatten.uniq
      end

      def find_required
        required = []
        child_keys.each do |child_key|
          required << child_key if required? child_key
        end
        required
      end
    end
  end
end
