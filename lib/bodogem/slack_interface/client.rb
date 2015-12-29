require 'slack-ruby-client'

module Bodogem
  module SlackInterface
    class Client
      def initialize(channel_name: nil, token: nil)
        @client = SlackInterface::Client.connect(token)
        @channel = @client.web_client.channels_list['channels'].detect { |c| c['name'] == channel_name }
        @queue = Queue.new

        # TODO: Bodogem と密結合になっているので、外に出したい.
        @client.on :message do |data|
          if current_channel?(data) && !self_message?(data)
            Bodogem.application.logger.info "GET DATA: #{data}"

            if @queue.num_waiting > 0
              @queue.push(data['text'])
            else
              Bodogem.application.router.dispatch(data['text'])
            end
          end
        end
      end

      def self.connect(token)
        return @client if @client

        Slack.configure { |config| config.token = token }

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

      def input(format: /\A.*\z/)
        text = nil

        loop do
          @queue.clear
          text = @queue.pop
          break if format === text
        end

        format.match(text)
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
