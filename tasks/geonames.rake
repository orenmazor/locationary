require 'msgpack'
require 'net/http'
require 'csv'
require 'zip/zip'
require 'snappy'
require 'benchmark'

namespace :geonames do
  desc 'create database'
  task :create do
    db_path = "#{Dir.pwd}/db/geonames.bin"
    zipdatafile = "#{Dir.pwd}/tmp/allCountries.zip"
    rawdata = "#{Dir.pwd}/tmp/allCountries.txt"
    data_headers = ["Country Code","Postal Code","Place Name","Name 1","Code 1","Name 2","Code 2","Name 3","Code 3","Latitude","Longitude","Accuracy"]

    if File.exist?(db_path)
      File.delete(db_path)
    end
    download_time = Benchmark.measure do
      Net::HTTP.start("download.geonames.org") do |http|
        resp = http.get("/export/zip/allCountries.zip")
        open(zipdatafile, "wb") do |file|
          file.write(resp.body)
        end
      end
    end
    puts "downloaded file in #{download_time.real} seconds"

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
            addresses[row["Postal Code"].downcase] = row.to_hash
          end
        end
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
end
