require "./tests/test_helper"
require "./lib/locationary"

class LookupTests < MiniTest::Unit::TestCase
  def setup
    @kanata = {"Country Code"=>"CA", "Postal Code"=>"K2K", "Place Name"=>"Kanata (Beaverbrook / South March)", "Name 1"=>"Ontario", "Code 1"=>"ON", "Name 2"=>nil, "Code 2"=>nil, "Name 3"=>nil, "Code 3"=>nil, "Latitude"=>"45.3704", "Longitude"=>"-75.9198", "Accuracy"=>"1"}
  end

  def test_locationary_finds_by_longitude_latitude
    assert_equal @kanata, Locationary.find({:longitude => @kanata[:longitude], :latitude => @kanata[:latitude]})
  end

  def test_locationary_finds_by_zipcode
    assert_equal @kanata, Locationary.find({:postalcode => "K2K"}, {:strict => true})
  end

  def test_strict_lookup_fails_quietly_on_wrong_data
    assert_equal nil, Locationary.find({:postalcode => "foobar"},{:strict => true})
  end

  def test_strict_lookup_works_on_valid_data
    assert_equal @kanata, Locationary.find({:postalcode => "K2K"},{:strict => true})
  end

  def test_postalcode_convenience_method
    assert_equal @kanata, Locationary.find_by_postalcode("K2K", {:strict => true})
  end

  def test_postalcode_fuzzy_search
    assert_equal @kanata, Locationary.find_by_postalcode("K2KX", {:strict => false})
  end

  def test_fuzzy_search_ignores_case
    assert_equal @kanata, Locationary.find_by_postalcode("k2k", {:strict => false})
  end

  def test_fuzzy_search_finds_full_postal_code
    assert_equal @kanata, Locationary.find_by_postalcode("k2k2k1", {:strict => false})
  end
end