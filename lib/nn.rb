require "kdtree"

module Locationary

  def Locationary.nn_data
    @kd ||= Locationary.load_nn_data
  end

  def Locationary.clear_nn_data
    @kd = nil
    @kd_lookup = nil
  end

  def Locationary.nn_lookup
    @kd_lookup ||= Locationary.load_nn_lookup
  end

  def Locationary.nearest_neighbour(latitude, longitude, options = {})
    num_matches = options[:num_matches] ||= 1

    results = []
    Locationary.nn_data.nearestk(latitude, longitude, num_matches).each do |match|
      results << Locationary.data[Locationary.nn_lookup[match]]
    end
    results
  end

  private

  def Locationary.load_nn_lookup
    lookup = []
    File.open("#{Dir.pwd}/db/lookup.txt") do |f|
      f.each { |l| lookup << l.strip }
    end
    lookup
  end

  def Locationary.load_nn_data
    kd = File.open("#{Dir.pwd}/db/kdtree.bin") { |f| Kdtree.new(f) }
  end

end