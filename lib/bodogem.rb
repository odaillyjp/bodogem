require "bodogem/version"
require "bodogem/configuration"
require "bodogem/slack_interface/client"
require "bodogem/slack_interface/router"

module Bodogem
  class << self
    def configuration
      @configuration ||= Bodogem::Configuration.new
    end

    def configure
      yield configuration if block_given?
      configuration.setting
    end

    def client
      configuration.client
    end

    def packages
      @packages ||= []
    end

    def run
      packages.each do |package|
        main_router.draw /\A#{package.title}をはじめる\z/ do
          client.puts "#{package.title}を準備しています..."
          game_router = Bodogem::SlackInterface::Router.new

          game_router.draw /\A#{package.title}をおわる\z/ do
            client.router = main_router
            client.puts "#{package.title}を終了しました"
          end

          client.router = game_router
          package.new.start
        end
      end

      client.router = main_router
      client.start
    end

    private

    def main_router
      @main_router ||= Bodogem::SlackInterface::Router.new
    end
  end
end
