require 'logger'

module Bodogem
  class Application
    class Configuration
      attr_accessor :channel, :token, :logger

      def initialize
        @channel = 'general'
        @token = nil
        @logger = nil
      end

      def log_level=(level)
        @log_level = case level
                     when :debug then Logger::DEBUG
                     when :info  then Logger::INFO
                     when :warn  then Logger::WARN
                     when :error then Logger::ERROR
                     when :fatal then Logger::FATAL
                     else raise
                     end
      end

      def setting
        setting_logger if logger.nil?
        self
      end

      def setting_logger
        @logger = Logger.new(STDOUT)
        @logger.level = @log_level || Logger::INFO
      end
    end
  end
end
