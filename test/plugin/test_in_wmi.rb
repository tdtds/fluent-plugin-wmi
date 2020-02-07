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
    test 'specify both "class_name" and "query"' do
      assert_raise(Fluent::ConfigError.new("Cannot specify both parameters 'class_name' and 'query'.")) {
        create_driver CONF + %[
          class_name Win32_Processor
          query "SELECT Role FROM Win32_Processor"
        ]
      }
    end

    test 'no "class_name" or "query"' do
      assert_raise(Fluent::ConfigError.new("'class_name' or 'query' parameter is requied.")) {
        create_driver CONF
      }
    end

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

    test 'valid query value' do
      query = "SELECT Role FROM Win32_Processor"
      d = create_driver CONF + %[
        query #{query}
      ]
      assert_equal(query, d.instance.query)
    end

    test 'invalid query value' do
      query = "Invalid Query"
      assert_raise(Fluent::ConfigError.new("#{query} is invalid query.")) {
        create_driver CONF + %[
          query #{query}
        ]
      }
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
    test 'test expects plugin emit a event by class_name' do
      d = create_driver CONF + %[
        class_name Win32_Processor
        interval 1
      ]
      d.run(expect_emits: 1, timeout: 10)
      d.events.each do |tag, time, value|
        assert_equal("monitor.wmi", tag)
        assert_not_equal(0, value.length)
        assert_equal("CPU", value["role"])
      end
    end

    test 'test expects plugin emit a event by query' do
      d = create_driver CONF + %[
        query "SELECT Role FROM Win32_Processor"
        interval 1
      ]
      d.run(expect_emits: 1, timeout: 10)
      d.events.each do |tag, time, value|
        assert_equal("monitor.wmi", tag)
        assert_not_equal(0, value.length)
        assert_equal("CPU", value["role"])
      end
    end
  end

  private

  def create_driver(conf = CONFIG)
    Fluent::Test::Driver::Input.new(Fluent::Plugin::WmiInput).configure(conf)
  end
end
