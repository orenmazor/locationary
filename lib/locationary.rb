require "locationary/version"
require "msgpack"
require "zlib"

module Locationary

  def Locationary.find(address = {}, options = {})
    Locationary.data
  end

  def Locationary.data
    @data ||= Locationary.load_data
  end

  private

  def Locationary.load_data
    raw = File.read("#{Dir.pwd}/db/geonames.bin")
    @data = MessagePack.unpack(Zlib::Inflate.inflate(raw))
  end

end
