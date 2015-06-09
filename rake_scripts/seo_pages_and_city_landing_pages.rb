Contentful
  module SEOPages
    AIRPORT_PATTERN = %r{^/airporttransfer/(?<city>.*)}
    LIMOUSINE_PATTERN = %r{^/limousineservice/(?<city>.*)}
    CHAUFFEUR_PATTERN = %r{^/chauffeurservice/(?<city>.*)}

    def self.map_seo_page_urls(old_seo_urls)
      hash_of_old_and_new_urls = {}
      old_seo_urls.each do |url|
        limousine_captures = url.match(LIMOUSINE_PATTERN)
        if limousine_captures
          hash_of_old_and_new_urls[url] = "/limousine-service-#{limousine_captures[:city]}"
          next
        end

        chauffeur_captures = url.match(CHAUFFEUR_PATTERN)
        if chauffeur_captures
          hash_of_old_and_new_urls[url] = "/chauffeur-service-#{chauffeur_captures[:city]}"
          next
        end

        airport_captures = url.match(AIRPORT_PATTERN)
        if airport_captures
          hash_of_old_and_new_urls[url] = "/airport-transfer-#{airport_captures[:city]}"
        end
      end

      hash_of_old_and_new_urls
    end
  end

  module CityPages
    CITY_PATTERN = %r{^/cities/(?<city>.*)}
    def self.map_city_landing_page_urls(old_city_urls)
      hash_of_old_and_new_urls = {}
      old_city_urls.each do |url|
        city_captures = url.match(CITY_PATTERN)
        if city_captures
          hash_of_old_and_new_urls[url] = "/cities-#{city_captures[:city]}"
          next
        end
      end

      hash_of_old_and_new_urls
    end
  end
end
