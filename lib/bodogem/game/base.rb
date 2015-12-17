module Bodogem
  module Game
    class Base
      def title
        @title ||= begin
          klass = self.class
          klass.respond_to?(:title) ? klass.title : klass.to_s
        end
      end

      def setting_client
        Bodogem.client.router.draw "#{title}をはじめる" do
          start
        end
      end

      def start
        raise
      end
    end
  end
end
