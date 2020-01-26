# SPDX-License-Identifier: Apache-2.0
# Copyright 2020- Tada, Tadashi

require "fluent/plugin/input"

module Fluent::Plugin
  class WmiInput < Fluent::Plugin::Input
    Fluent::Plugin.register_input("wmi", self)

    def configure(conf)
      super
    end

    def start
      super
      tag = "wmi.test"
      time = Fluent::Engine.now
      record = {"plugin"=>"wmi"}
      router.emit(tag, time, record)
    end

    def shutdown
      super
    end
  end
end
