module Bodogem
  class Configuration
    attr_accessor :channel, :token
    attr_reader :client

    def initialize
      @channel = 'general'
      @token = nil
      @client = nil
    end

    def setting
      @client = Bodogem::SlackInterface::Client.new(channel)
      @client.start
    end
  end
end
