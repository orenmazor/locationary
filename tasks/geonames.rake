require 'msgpack'
require 'net/http'
require 'csv'
require 'zip/zip'
require 'snappy'
require 'benchmark'

namespace :geonames do
  desc 'create database'
  task :create do
    target_environment = "#{ENV['RACK_ENV']}"
    db_path = "./db/geonames.bin"
    zipdatafile = "./tmp/allCountries.zip"
    rawdata = "./tmp/allCountries.txt"
    data_headers = ["Country Code","Postal Code","Place Name","Province","Province Shortcode","City","City Shortcode","Region","Region Shortcode","Latitude","Longitude","Accuracy"]
    canada_data_path = "./db/raw/canada.csv"
    result_headers = ["Postal Code", "Latitude", "Longitude", "City", "Province", "Country"]

    if File.exist?(db_path)
      File.delete(db_path)
    end

    begin
      download_time = Benchmark.measure do
        Net::HTTP.start("download.geonames.org") do |http|
          resp = http.get("/export/zip/allCountries.zip")
          open(zipdatafile, "wb") do |file|
            file.write(resp.body)
          end
        end
      end
      puts "downloaded file in #{download_time.real} seconds"
    end

    addresses = {}

    parse_time = Benchmark.measure do
      Zip::ZipFile.open(zipdatafile) do |zipfile|
        zipfile.each do |file|
          FileUtils.mkdir_p(File.dirname(rawdata))
          zipfile.extract(file, rawdata) unless File.exist?(rawdata)
          data = File.read(rawdata)

          data.gsub!('"','')
          data.gsub!('\'','')
          CSV.parse(data, {:col_sep => "\t", :headers=>data_headers, :force_quotes => true}).each do |row|
            #Canada is special
            if not ["CA"].include?(row["Country Code"])
              addresses[row["Postal Code"].upcase] = row.to_hash.select {|k,v| result_headers.include?(k) }
            end
          end
        end
      end

      #canada is special
      canada_data = File.read(canada_data_path)
      CSV.parse(canada_data, :headers=>["Postal Code","Latitude","Longitude","City","Province Shortcode","Province","Country","Country Shortcode"]).each do |row|
        addresses[row["Postal Code"].upcase] = row.to_hash.select {|k,v| result_headers.include?(k) }
      end

    end
    puts "parsed data into address structure in #{parse_time.real} seconds"

    compress_time = Benchmark.measure do
      File.open(db_path,"w") do |file|
        file.write(Snappy.deflate(addresses.to_msgpack))
      end
    end
    puts "compressed and written data store to disk in #{compress_time.real} seconds"
  end

  desc 'statistics'
  task :stats do
    db = Locationary.data
    results = {:country => {}}

    db.values.each do |location|
      results[:country][location[:Country]] += 1
    end

    puts results.inspect
  end
end
