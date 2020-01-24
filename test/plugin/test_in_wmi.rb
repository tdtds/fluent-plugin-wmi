require "helper"
require "fluent/plugin/in_wmi.rb"

class WmiInputTest < Test::Unit::TestCase
  setup do
    Fluent::Test.setup
  end

  test "failure" do
    flunk
  end

  private

  def create_driver(conf)
    Fluent::Test::Driver::Input.new(Fluent::Plugin::WmiInput).configure(conf)
  end
end
