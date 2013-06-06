require "./tests/test_helper"
require "./lib/locationary"

class LookupTests < MiniTest::Unit::TestCase
  def test_locationary_finds_by_longitude_latitude
    actual = {"Country Code"=>"CA", "Postal Code"=>"K2K", "Place Name"=>"Kanata (Beaverbrook / South March)", "Name 1"=>"Ontario", "Code 1"=>"ON", "Name 2"=>nil, "Code 2"=>nil, "Name 3"=>nil, "Code 3"=>nil, "Latitude"=>"45.3704", "Longitude"=>"-75.9198", "Accuracy"=>"1"}
    assert_equal Locationary.find({:longitude => actual[:longitude], :latitude => actual[:latitude]}), actual
  end

  def test_locationary_finds_by_zipcode
    actual = {"Country Code"=>"CA", "Postal Code"=>"K2K", "Place Name"=>"Kanata (Beaverbrook / South March)", "Name 1"=>"Ontario", "Code 1"=>"ON", "Name 2"=>nil, "Code 2"=>nil, "Name 3"=>nil, "Code 3"=>nil, "Latitude"=>"45.3704", "Longitude"=>"-75.9198", "Accuracy"=>"1"}
    assert_equal Locationary.find({:postalcode => "K2K"}, {:strict => true}), actual
  end

  def test_strict_lookup_fails_quietly_on_wrong_data
    assert_equal nil, Locationary.find({:postalcode => "foobar"},{:strict => true})
  end

  def test_strict_lookup_works_on_valid_data
    actual = {"Country Code"=>"CA", "Postal Code"=>"K2K", "Place Name"=>"Kanata (Beaverbrook / South March)", "Name 1"=>"Ontario", "Code 1"=>"ON", "Name 2"=>nil, "Code 2"=>nil, "Name 3"=>nil, "Code 3"=>nil, "Latitude"=>"45.3704", "Longitude"=>"-75.9198", "Accuracy"=>"1"}
    assert_equal actual, Locationary.find({:postalcode => "K2K"},{:strict => true})
  end
end