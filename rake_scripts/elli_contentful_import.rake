re "helpers/elli_to_contentful_helper"
require "yaml"
include ElliToContentful

namespace :ElliToContentful do
  desc "Login to the APHRODITE SPACE on Contentful, and create new entries for the given Elli pages"
  task push_pages_to_contentful: :environment do
    ElliToContentful.authorize_contentful(
        ENV["CONTENTFUL_DELIVERY_ACCESS_TOKEN"],
        ENV["CONTENTFUL_MANAGEMENT_ACCESS_TOKEN"],
        ENV["CONTENTFUL_APHRODITE_SPACE_ID"]
        )
    space = ElliToContentful.find_space(ENV["CONTENTFUL_APHRODITE_SPACE_ID"])
    seo_lp_content_type = space.content_types.find(ENV["CONTENTFUL_APHRODITE_SEO_CONTENT_TYPE"])
    career_pages_content_type = space.content_types.find(ENV["CONTENTFUL_APHRODITE_CAREER_CONTENT_TYPE"])
    business_district_id = ENV["CONTENTFUL_APHRODITE_BUSINESS_DISTRICT"]
    elli_airport_transfer_pages = "airport_transfer"
    elli_limousine_service_pages = "limousine_service"
    elli_chauffeur_service_pages = "chauffer_service"
    elli_career_pages = "career"
    german_locale = "de-DE"
    ElliToContentful.map_contentful_business_districts(space, business_district_id)
    ElliToContentful.create_new_entries_from_landingpages(
        seo_lp_content_type,
        elli_airport_transfer_pages,
        german_locale
        )
    EllitoContentful.create_new_entries_from_landingpages(
        seo_lp_content_type,
        elli_chauffeur_service_pages,
        german_locale
        )
    EllitoContentful.create_new_entries_from_landingpages(
        seo_lp_content_type,
        elli_limousine_service_pages,
        german_locale
        )
    ElliToContentful.create_new_entries_from_landingpages(
        career_content_type,
        elli_career_pages,
        german_locale
        )
  end
  desc "Login to the APHRODITE SPACE on CONTENTFUL and replace old Elli 'golden-colored' images with new blue images"
  task replace_images: :environment do
    ElliToContentful.authorize_contentful(
        ENV["CONTENTFUL_DELIVERY_ACCESS_TOKEN"],
        ENV["CONTENTFUL_MANAGEMENT_ACCESS_TOKEN"],
        ENV["CONTENTFUL_APHRODITE_SPACE_ID"]
        )
    space = ElliToContentful.find_space(ENV["CONTENTFUL_APHRODITE_SPACE_ID"])
    seo_lp_content_type = space.content_types.find(ENV["CONTENTFUL_APHRODITE_SEO_CONTENT_TYPE"])
    german_locale = "de-DE"
    elli_to_aphrodite_images = YAML::load_file(File.open('lib/helpers/elli_to_aphrodite_images.yml'))
    elli_to_aphrodite_images.each_pair do |elli_image, aphrodite_image|
        ElliToContentful.access_images_for_replacement(
            seo_lp_content_type,
            german_locale,
            elli_image,
            aphrodite_image
        )
    end
  end
end
