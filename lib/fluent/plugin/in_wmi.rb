# SPDX-License-Identifier: Apache-2.0
# Copyright 2020- Tada, Tadashi

require "fluent/plugin/input"
require "wmi-lite"

module Fluent::Plugin
  class WmiInput < Fluent::Plugin::Input
    Fluent::Plugin.register_input("wmi", self)
    helpers :timer

    desc "The value is the tag assigned to the generated events."
    config_param :tag, :string
    desc "The value is the instance name of WMI."
    config_param :class_name, :string
    desc "Determine the rate to emit metrics as events."
    config_param :interval, :time, default: 10

    def configure(conf)
      super
      raise Fluent::ConfigError, "class_name is required." unless @class_name
      begin
        WmiLite::Wmi.new.instances_of(@class_name)
      rescue WmiLite::WmiException
        raise Fluent::ConfigError, "#{@class_name} is invalid class_name."
      end
      raise Fluent::ConfigError, "interval must be larger than 1." if @interval < 1
    end

    def start
      super
      timer_execute(:wmi_timer, @interval) do
        wmi = WmiLite::Wmi.new
        time = Fluent::Engine.now
        wmi.instances_of(@class_name).each do |instance|
          router.emit(@tag, time, instance.property_map)
        end
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
