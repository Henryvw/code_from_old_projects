require "dotenv"
require "dotenv/tasks"
require "contentful/management"
require "pry"
require "./test_pages"
require "./city_pages"
require "./contentful_legacy_urls"
require "yaml"
Dotenv.load

module Contentful

  def self.create_access_instance(access_token)
    Contentful::Management::Client.new(access_token)
  end

  def self.find_space(space_id)
    Contentful::Management::Space.find(space_id)
  end

  def self.print_old_entries(entries, field)
    puts ""
    puts "List of original URLs:"

    entries.each do |entry|
      puts entry.fields[field]
    end
  end

  def self.print_new_entries(entries, field)
    puts ""
    puts "List of new URLs that the script has replaced them with:"

    entries.each do |entry|
      puts entry.fields[field]
    end
  end

  def self.update_entry_fields(space, content_type, field, new_content_hash)
    entries = space.entries.all(limit: 1000, content_type: content_type.id)

    Contentful.print_old_entries(entries, field)

    entries.each do |entry|
      old_content = entry.fields[field]
      new_content = new_content_hash.fetch(old_content) 
      entry.update(field => new_content)
    end

    Contentful.print_new_entries(entries, field)
  end
end

namespace :contentful do
  desc "Login to a TEST SPACE on Contentful, and Update A Field in the Given Entries"
  task :update_test_space => :dotenv do
    access_contentful = Contentful.create_access_instance(ENV["ACCESS_CONTENT_TOKEN"])
    space = Contentful.find_space(ENV["TEST_SOURCE_SPACE_ID"])
    content_type = space.content_types.find(ENV["TEST_SOURCE_CONTENT_ID"])
    field = :urlPath
    new_content_hash = MIDDLE_EARTH_SEO_PAGES
    Contentful.update_entry_fields(space, content_type, field, new_content_hash)
  end

  desc "Login to APHRODITE'S CONTENTFUL SPACE, and Update URLs in City Landing Pages"
  task :update_city_pages => :dotenv do
    access_contentful = Contentful.create_access_instance(ENV["ACCESS_CONTENT_TOKEN"])
    space = Contentful.find_space(ENV["APHRODITE_SPACE_ID"])
    content_type = space.content_types.find(ENV["APHRODITE_CITY_PAGE_ID"])
    field = :urlPath
    new_content_hash = CITY_LANDING_PAGES
    Contentful.update_entry_fields(space, content_type, field, new_content_hash)
  end

  desc "Login to APHRODITE'S CONTENTFUL SPACE, and Update URLs in Legacy SEO Pages"
  task :update_seo_pages => :dotenv do
    access_contentful = Contentful.create_access_instance(ENV["ACCESS_CONTENT_TOKEN"])
    space = Contentful.find_space(ENV["APHRODITE_SPACE_ID"])
    content_type = space.content_types.find(ENV["APHRODITE_SEO_PAGE_ID"])
    field = :urlPath
    new_content_hash = SEO_PAGES
    Contentful.update_entry_fields(space, content_type, field, new_content_hash)
  end
end
