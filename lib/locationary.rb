require "locationary/version"
require "msgpack"
require "snappy"
require "levenshtein"

module Locationary

  def Locationary.find(address = {}, options = {:strict => true})
    return Locationary.data[address[:postalcode]] if options[:strict]
  end

  def Locationary.data
    @data ||= Locationary.load_data
  end

  private

  def Locationary.load_data
    raw = File.read("#{Dir.pwd}/db/geonames.bin")
    @data = MessagePack.unpack(Snappy.inflate(raw))
  end

end
