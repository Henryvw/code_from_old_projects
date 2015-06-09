require "yaml"
yaml_test_file = YAML.load_file("./contentful_cities.yml")
cities = yaml_test_file[:contentful_cities]

CITY_LANDING_PAGES = {}
  cities.each do |city|
    CITY_LANDING_PAGES["/cities/#{city}"] = "/cities-#{city}"
  end
