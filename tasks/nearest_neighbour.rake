require 'kdtree'
require "./lib/locationary"
require "./lib/nn"

namespace :nearest_neighbour do
  desc 'persist nearest neighbour structure'
  task :create do
    db_path = "#{Dir.pwd}/db/kdtree.bin"
    lookup_path = "#{Dir.pwd}/db/lookup.txt"
    points = []
    lookup = []
    i = 0

    build_time = Benchmark.measure do
      Locationary.data.each do |location|
        lat = location[1]['Latitude']
        lon = location[1]['Longitude']
        if !lat.nil? and !lon.nil?
          points << [Float(location[1]['Latitude']), Float(location[1]['Longitude']), i]
          lookup << location[0]
          i += 1
        end
      end
      kd = Kdtree.new(points)

      File.open(db_path,"w") do |file|
        kd.persist(file)
      end

      File.open(lookup_path, "w") do |file|
        lookup.each { |l| file.write("#{l}\n") }
      end
    end
    puts "nearest-neighbour tree built in #{build_time.real} seconds"
  end
end
