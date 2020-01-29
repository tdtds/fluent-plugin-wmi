# SPDX-License-Identifier: Apache-2.0
# Copyright 2020- Tada, Tadashi

require "fluent/plugin/input"
require "wmi-lite"

module Fluent::Plugin
  class WmiInput < Fluent::Plugin::Input
    Fluent::Plugin.register_input("wmi", self)

    def configure(conf)
      super
    end

    def start
      super
      wmi = WmiLite::Wmi.new
      instances = wmi.instances_of('Win32_Processor')
      tag = "monitor.wmi"
      time = Fluent::Engine.now
      record = instance_to_hash(instances)
      router.emit(tag, time, record)
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