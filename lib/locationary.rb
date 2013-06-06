require "locationary/version"
require "msgpack"
require "snappy"

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
    @data = MessagePack.unpack(Snappy.inflate(raw))
  end

  PROPERTIES = {
    postal_code: "Postal Code",
    country_code: "Country Code",
    state: "Name 1",
    province: "Name 2",
    community: "Name 3"
  }

  PROPERTIES.each do |location_prop|
    class_eval <<-RUBY, __FILE__, __LINE__ +1
      def Locationary.find_by_#{location_prop[0].to_s}(val)
        Locationary.data
      end
    RUBY
  end
end
