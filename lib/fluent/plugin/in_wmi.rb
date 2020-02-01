# SPDX-License-Identifier: Apache-2.0
# Copyright 2020- Tada, Tadashi

require "fluent/plugin/input"
require "wmi-lite"

module Fluent::Plugin
  class WmiInput < Fluent::Plugin::Input
    Fluent::Plugin.register_input("wmi", self)

    desc "The value is the tag assigned to the generated events."
    config_param :tag, :string

    desc "The value is the instance name of WMI."
    config_param :class_name, :string

    def configure(conf)
      super

      raise Fluent::ConfigError, "class_name is required." unless @class_name
    end

    def start
      super
      wmi = WmiLite::Wmi.new
      time = Fluent::Engine.now
      wmi.instances_of(@class_name).each do |instance|
        router.emit(@tag, time, instance.property_map)
      end
    end

    def shutdown
      super
    end
  end
end

class WmiLite::Wmi::Instance
  attr_reader :property_map
end