require 'jsonpath'

module JSON
  class SchemaGenerator
    class BruteForceRequiredSearch
      def initialize(data)
        @data = data.dup
        @json_path = data.is_a?(Array) ? ['$[*]'] : ['$']
      end

      def push(key, value)
        @json_path.push value.is_a?(Array) ? "#{key}[*]" : key
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
        child_keys.select {|k| required? k}
      end
    end
  end
end
