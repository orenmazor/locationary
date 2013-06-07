require "./tests/test_helper"
require "./lib/nn"

class NearestNeighbourLookupTests < MiniTest::Unit::TestCase
  def test_finds_single_nearest_neighbour
    actual = {"Country Code"=>"US", "Postal Code"=>"90042", "Place Name"=>"Los Angeles", 
              "Name 1"=>"California", "Code 1"=>"CA", "Name 2"=>"Los Angeles", 
              "Code 2"=>"037", "Name 3"=>nil, "Code 3"=>nil, "Latitude"=>"34.1145", 
              "Longitude"=>"-118.1929", "Accuracy"=>nil }
    assert_equal Locationary.nearest_neighbour(34.1, -118.2)[0], actual
  end

  def test_finds_multiple_nearest_neighbours
    actual = ["K2P", "K1N", "K1A"]

    results = Locationary.nearest_neighbour(45.42083333333334, -75.69, num_matches: 3)
    assert_equal results.length, 3
    assert_equal results[0]["Postal Code"], actual[0]
    assert_equal results[1]["Postal Code"], actual[1]
    assert_equal results[2]["Postal Code"], actual[2]
  end

  def test_persists_nn_data_if_empty
    Locationary.clear_nn_data

    actual = "K2P"
    results = Locationary.nearest_neighbour(45.42083333333334, -75.69)
    assert_equal results[0]["Postal Code"], actual
  end
end
