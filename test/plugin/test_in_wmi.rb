require "helper"
require "fluent/plugin/in_wmi.rb"

class WmiInputTest < Test::Unit::TestCase
  setup do
    Fluent::Test.setup
  end

  CONFIG = %[
    tag monitor.wmi
    class_name Win32_Processor
  ]

  sub_test_case 'plugin will emit a test event' do
    test 'test expects plugin emit a event' do
      d = create_driver

      d.run(expect_emits: 1, timeout: 10)
      events = d.events
      assert_equal("monitor.wmi", events[0][0])
      assert_not_equal(0, events[0][2].length)
      assert_equal("CPU", events[0][2]["role"])
    end
  end

  private

  def create_driver(conf = CONFIG)
    Fluent::Test::Driver::Input.new(Fluent::Plugin::WmiInput).configure(conf)
  end
end
