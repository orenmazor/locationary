require "./tests/test_helper"
require "./lib/locationary"

class LookupTests < MiniTest::Unit::TestCase
  def test_locationary_finds_by_longitude_latitude
    actual = {:country => :Canada, :province => :Ontario, :city => :Ottawa, :zipcode => :K2K2K1}
    assert_equal Locationary.find({:zipcode => :K2K2K1}), actual
  end

  def test_locationary_finds_by_zipcode
    actual = {:country => :Canada, :province => :Ontario, :city => :Ottawa, :zipcode => :K2K2K1}
    assert_equal Locationary.find({:longitude => actual[:longitude], :latitude => actual[:latitude]}), actual
  end
end