module JSON
  class SchemaGenerator
    class StatementGroup
      def initialize key = nil
        @key = key
        @statements = []
      end

      def add statement
        @statements << statement
      end

      def to_s
        buffer = StringIO.new
        if @key.nil?
          buffer.puts "{"
        else 
          buffer.puts "\"#{@key}\": {"
        end
        buffer.puts @statements.join ', '
        buffer.puts "}"
        buffer.string
      end
    end
  end
end