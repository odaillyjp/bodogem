require "bodogem/version"
require "bodogem/application"
require "bodogem/application/configuration"
require "bodogem/router"
require "bodogem/slack_interface/client"

module Bodogem
  class << self
    def application
      @application ||= Application.instance
    end
  end
end
