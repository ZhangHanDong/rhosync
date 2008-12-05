require 'test_helper'

describe "Source", ActiveSupport::TestCase do
  # Replace this with your real tests.
  it "should load fixtures" do
    dir=File.dirname(__FILE__)
    p dir
    Fixtures.create_fixtures(dir, "sources")
  end
end
