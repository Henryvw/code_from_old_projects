require "yaml"
yaml_test_file = YAML.load_file("./test_cities.yml")
middle_earth_cities = yaml_test_file[:middle_earth_cities]

MIDDLE_EARTH_SEO_PAGES = {}
middle_earth_cities.each do |city|
  MIDDLE_EARTH_SEO_PAGES["/airporttransfer/#{city}"] = "/airport-transfer-#{city}"
  MIDDLE_EARTH_SEO_PAGES["/limousineservice/#{city}"] = "/limousine-service-#{city}"
  MIDDLE_EARTH_SEO_PAGES["/chauefferservice/#{city}"] = "/chauffeur-service-#{city}"
end