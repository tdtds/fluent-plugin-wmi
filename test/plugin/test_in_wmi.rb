require "helper"
require "fluent/plugin/in_wmi.rb"

class WmiInputTest < Test::Unit::TestCase
  setup do
    Fluent::Test.setup
  end

  CONFIG = %[
  ]

  sub_test_case 'plugin will emit a test event' do
    test 'test expects plugin emit a event' do
      d = create_driver

      d.run(expect_emits: 1, timeout: 10)
      events = d.events
      assert_equal("wmi.test", events[0][0])
      assert_equal({"plugin"=>"wmi"}, events[0][2])
    end
  end

  private

  def create_driver(conf = CONFIG)
    Fluent::Test::Driver::Input.new(Fluent::Plugin::WmiInput).configure(conf)
  end
end
