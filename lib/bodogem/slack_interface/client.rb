require 'slack-ruby-client'

module Bodogem
  module SlackInterface
    class Client
      attr_reader :client

      def initialize(channel_name)
        @client = SlackInterface::Client.connect
        @channel = @client.web_client.channels_list['channels'].detect { |c| c['name'] == channel_name }

        @client.on :message do |data|
          if current_channel?(data) && !self_message?(data)
            Bodogem.application.logger.info "GET DATA: #{data}"
            Bodogem.application.router.dispatch(data['text'])
          end
        end
      end

      def self.connect
        return @client if @client

        Slack.configure do |config|
          config.token = Bodogem.application.config.token
        end

        @client = Slack::RealTime::Client.new
        @client.web_client.auth_test
        @client
      end

      def start
        @client.start!
      end

      def puts(text)
        @client.web_client.chat_postMessage(channel: @channel['id'], text: text, as_user: true)
      end

      private

      def current_channel?(data)
        data['channel'] == @channel['id']
      end

      def self_message?(data)
        data['user'] == @client.self['id']
      end
    end
  end
end
