require "helper"
require "fluent/plugin/in_wmi.rb"

class WmiInputTest < Test::Unit::TestCase
  setup do
    Fluent::Test.setup
  end

  CONF = %[
    tag monitor.wmi
  ]

  sub_test_case 'configuration' do
    test 'valid class_name value' do
      d = create_driver CONF + %[
        class_name Win32_Processor
      ]
      assert_equal('Win32_Processor', d.instance.class_name)
    end

    test 'invalid class_name value' do
      class_name = "Invalid_Class_Name"
      assert_raise(Fluent::ConfigError.new("#{class_name} is invalid class_name.")) {
        create_driver CONF + %[
          class_name #{class_name}
        ]
      }
    end

    test 'valid interval value' do
      d = create_driver CONF + %[
        class_name Win32_Processor
        interval 10
      ]
      assert_equal(10, d.instance.interval)
    end

    test 'invalid inteaval value' do
      assert_raise(Fluent::ConfigError) {
        create_driver CONF + %[
          class_name Win32_Processor
          interval 0
        ]
      }
    end
  end

  sub_test_case 'plugin will emit a test event' do
      test 'test expects plugin emit a event' do
      d = create_driver CONF + %[
        class_name Win32_Processor
        interval 1
      ]

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
