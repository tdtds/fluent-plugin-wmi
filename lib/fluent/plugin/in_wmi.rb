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
    config_param :instance_of, :string

    def configure(conf)
      super

      raise Fluent::ConfigError, "instance_of is required." unless @instance_of
    end

    def start
      super
      wmi = WmiLite::Wmi.new
      instances = wmi.instances_of(@instance_of)
      time = Fluent::Engine.now
      record = instance_to_hash(instances)
      router.emit(@tag, time, record)
    end

    def shutdown
      super
    end

  private
    def instance_to_hash(instances)
      a = []
      instances.each do |instance|
        a << instance.property_map
      end
      return a
    end
  end
end

class WmiLite::Wmi::Instance
  attr_reader :property_map
end