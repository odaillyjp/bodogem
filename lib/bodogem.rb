require "bodogem/version"
require "bodogem/configuration"
require "bodogem/slack_interface/client"
require "bodogem/slack_interface/router"
require "bodogem/game/base"

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

    def run
    end
  end
end
