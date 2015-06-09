require "./lib/contentful/seo_pages_and_city_landing_pages"
require "contentful/management"

module Contentful
  def self.create_access_instance(access_token)
    Contentful::Management::Client.new(access_token)
  end

  def self.find_space(space_id)
    Contentful::Management::Space.find(space_id)
  end

  def self.download_original_entries_as_hash(space, content_type, field)
    entries = space.entries.all(limit: 1000, content_type: content_type.id)
    original_content = []
    entries.each do |entry|
      original_entry = entry.fields[field]
      original_content << original_entry unless original_entry.nil?
    end

    original_content
  end

  def self.update_relevant_entries(space, content_type, field, new_content_hash)
    entries = space.entries.all(limit: 1000, content_type: content_type.id)
    puts "Starting update in #{field}..."

    entries.each do |entry|
      old_content = entry.fields[field]
      begin
        new_content = new_content_hash.fetch(old_content)
        entry.update(field => new_content)
      rescue KeyError
        puts "#{old_content} => SKIPPING B/C KEY NOT MAPPED"
      else
        puts "#{old_content}: #{new_content} => UPDATE SUCCESSFUL!"
      end
    end
  end
end

namespace :contentful do
  desc "Login to a TEST SPACE on Contentful, and Update A Field in the Given Entries"
  task update_test_space: :environment do
    Contentful.create_access_instance(ENV["CONTENTFUL_MANAGEMENT_API_ACCESS_TOKEN"])
    space = Contentful.find_space(ENV["CONTENTFUL_TEST_SPACE_ID"])
    content_type = space.content_types.find(ENV["TEST_SPACE_CONTENT_ID"])
    field = :urlPath
    original_entries = Contentful.download_original_entries_as_hash(space, content_type, field)
    new_seo_urls = Contentful::SEOPages.map_seo_page_urls(original_entries)
    new_city_urls = Contentful::CityPages.map_city_landing_page_urls(original_entries)
    Contentful.update_relevant_entries(space, content_type, field, new_city_urls)
    Contentful.update_relevant_entries(space, content_type, field, new_seo_urls)
  end

  desc "Login to APHRODITE'S CONTENTFUL SPACE, and Update URLs in City Landing Pages"
  task update_city_pages: :environment do
    Contentful.create_access_instance(ENV["CONTENTFUL_MANAGEMENT_API_ACCESS_TOKEN"])
    space = Contentful.find_space(ENV["CONTENTFUL_APHRODITE_SPACE_ID"])
    content_type = space.content_types.find(CONTENTFUL_CONFIG["mapping"]["city_landing_page"])
    field = :urlPath
    original_entries = Contentful.download_original_entries_as_hash(space, content_type, field)
    new_content_hash = Contentful::CityPages.map_city_landing_page_urls(original_entries)
    Contentful.update_relevant_entries(space, content_type, field, new_content_hash)
  end

  desc "Login to APHRODITE'S CONTENTFUL SPACE, and Update URLs in Legacy SEO Pages"
  task update_seo_pages: :environment do
    Contentful.create_access_instance(ENV["CONTENTFUL_MANAGEMENT_API_ACCESS_TOKEN"])
    space = Contentful.find_space(ENV["CONTENTFUL_APHRODITE_SPACE_ID"])
    content_type = space.content_types.find(CONTENTFUL_CONFIG["mapping"]["seo_page"])
    field = :urlPath
    original_entries = Contentful.download_original_entries_as_hash(space, content_type, field)
    new_content_hash = Contentful::SEOPages.map_seo_page_urls(original_entries)
    Contentful.update_relevant_entries(space, content_type, field, new_content_hash)
  end
end
