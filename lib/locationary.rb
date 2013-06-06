require "locationary/version"
require "msgpack"
require "snappy"
require "levenshtein"

module Locationary

  def Locationary.find(query, options = {:strict => true})
    if options[:strict]
      return Locationary.data[query[:postalcode].downcase]
    else
      return Locationary.fuzzy(query[:postalcode].downcase)
    end
  end

  def Locationary.fuzzy(query)
    best_score = 9999999999
    best_match = nil
    Locationary.data.keys.each do |key|
      new_score = Levenshtein.distance(key,query)
      if new_score < best_score
        best_score = new_score
        best_match = key
      end
    end

    [Locationary.data[best_match], {:levenstein => best_score}]
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
    postalcode: "Postal Code",
    country_code: "Country Code",
    state: "Name 1",
    province: "Name 2",
    community: "Name 3"
  }

  PROPERTIES.each do |location_prop|
    class_eval <<-RUBY, __FILE__, __LINE__ +1
      def Locationary.find_by_#{location_prop[0].to_s}(val, options)
        Locationary.find({"#{location_prop[0]}".to_sym => val}, options)
      end
    RUBY
  end
end
