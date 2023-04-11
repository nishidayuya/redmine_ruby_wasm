# Load the Redmine helper
require File.expand_path("../../../test/test_helper", __dir__)

Capybara.default_max_wait_time = 10

module RedmineRubyWasm::Lettable
  def let(name, &block)
    instance_variable_name = :"@__let__#{name}"
    define_method(name) {
      if instance_variable_defined?(instance_variable_name)
        instance_variable_get(instance_variable_name)
      else
        instance_exec(&block).tap do |result|
          instance_variable_set(instance_variable_name, result)
        end
      end
    }
  end

  def let!(name, &block)
    let(name, &block)
    setup(name)
  end
end

module RedmineRubyWasm::SystemTestAssertions
  extend ActiveSupport::Concern

  def assert_selector_inner_text_equal(selector, expected_text)
    assert_equal(expected_text, first(selector).text)
  end
end

class RedmineRubyWasm::ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  extend RedmineRubyWasm::Lettable
  include RedmineRubyWasm::SystemTestAssertions

  driven_by(
    :selenium,
    using: :headless_chrome,
    screen_size: [1024, 900], # same as https://github.com/redmine/redmine/blob/5.0.2/test/application_system_test_case.rb#L49
  ) do |driver_option|
    ENV.fetch("GOOGLE_CHROME_ARGS", "").split(",").each do |chrome_argument|
      driver_option.add_argument(chrome_argument)
    end
  end

  setup do
    Setting.delete_all
    Setting.clear_cache
  end
end
