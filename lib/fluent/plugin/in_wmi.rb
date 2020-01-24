# SPDX-License-Identifier: Apache-2.0
# Copyright 2020- Tada, Tadashi

require "fluent/plugin/input"

module Fluent
  module Plugin
    class WmiInput < Fluent::Plugin::Input
      Fluent::Plugin.register_input("wmi", self)
    end
  end
end
