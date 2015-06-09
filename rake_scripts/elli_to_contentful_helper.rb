module ElliToContentful

  ENGLISH_LOCALE = "en-US"
  GERMAN_LOCALE  = "de-DE"

  def self.authorize_contentful(delivery_api_token, management_api_token, space)
    Contentful::Client.new(access_token: delivery_api_token, space: space)
    Contentful::Management::Client.new(management_api_token)
  end

  def self.find_space(space_id)
    Contentful::Management::Space.find(space_id)
  end

  def self.map_contentful_business_districts(space, business_district)
    contentful_business_districts = space.entries.all(limit: 5000, content_type: business_district)
    @contentful_business_district_uuid_map =
      contentful_business_districts.each_with_object({}) do |business_district_object, acc|
        acc[business_district_object.uuid] = business_district_object
    end
  end

  def self.download_business_districts(space, content_type)
    elli_business_districts = BusinessDistrict.all
    elli_business_districts.each do |elli_biz_district|
      elli_biz_hash = {
        name: elli_biz_district.name,
        uuid: elli_biz_district.uuid
      }
      biz_distr_cont_typ = space.content_types.find(content_type)
      biz_distr_cont_typ.entries.create(elli_biz_hash)
    end
  end

  def self.create_new_entries_from_landingpages(contentful_content_type, elli_context, contentful_locale)
    logger.info ("#{"\n" *10} Starting to update #{contentful_content_type.name}... on #{Time.now}")
    Page.where(context: elli_context, language: "en").each do |elli_page|
      process_elli_page(elli_page, contentful_content_type)
    end
  end

  def self.access_images_for_replacement(contentful_content_type, locale, elli_image, aphrodite_image)
    logger.info ("Starting to replace #{elli_image} in #{contentful_content_type.name}... on #{Time.now}")
    contentful_english_pages = contentful_content_type.entries.all
    contentful_german_pages = contentful_content_type.entries.all(locale: locale)
    ElliToContentful.replace_image(contentful_english_pages, elli_image, aphrodite_image)
    ElliToContentful.replace_image(contentful_german_pages, elli_image, aphrodite_image)
  end

  private
  def self.logger
    @logger ||= Logger.new("#{Rails.root}/log/elli_to_contentful.log").tap do |logger|
      logger.level = Logger::INFO
    end
  end

  def self.process_elli_page(elli_page, contentful_content_type)
    elli_en_page_contents = build_page_info_hash(elli_page) { strip_en_or_de_from_urls(elli_page, "/en/") }
    contentful_english_pages =
      create_or_update_page(elli_page, "ENGLISH") { contentful_content_type.entries.create(elli_en_page_contents) }
    logger.info "Starting German update in #{contentful_content_type.name}..."
    elli_german_pages =
      Page.find(context: elli_page.context, translation_key: elli_page.translation_key, language: "de")
    if elli_german_pages
      elli_de_page_contents =
        build_page_info_hash(elli_german_pages) { |elli_page| strip_en_or_de_from_urls(elli_page, "/de/") }
      create_or_update_page(elli_page, "GERMAN") do
        contentful_german_pages = contentful_english_pages
        contentful_german_pages.locale = GERMAN_LOCALE
        contentful_german_pages.update(elli_de_page_contents)
      end
    end
  end

  def self.create_or_update_page(elli_page, language, &block)
    logger.info "#{elli_page.title} => NEW #{language} CONTENTFUL ENTRY CREATED!"
    begin
      yield
    rescue NoMethodError
      logger.info " ---- #{elli_page.title} => SKIPPING BECAUSE MISSING AN #{language} PIECE OF CONTENT ---- "
    end
  end

  def self.strip_en_or_de_from_urls(elli_page, url_piece)
    elli_url = elli_page.url
    if elli_url.include?(url_piece)
      elli_url.slice!(url_piece)
      elli_url = "/" << elli_url
    end
    elli_url
  end

  def self.build_page_info_hash(elli_page, &block)
    elli_url = yield(elli_page)
    info = {
      title: elli_page.title,
      urlPath: elli_url,
      description: elli_page.description,
      headline: elli_page.headline,
    }
    ElliToContentful.add_business_district_and_translation_to_hash(elli_page, info)
    info
  end

  def self.add_business_district_and_translation_to_hash(elli_page, info)
    if elli_page.business_district
      uuid = elli_page.business_district.uuid
      info[:businessDistrict] = @contentful_business_district_uuid_map[uuid]
    end
    if elli_page.translation
      info[:content] = ReverseMarkdown.convert(elli_page.translation.value)
    end
  end

  def self.replace_image(contentful_pages, elli_image, aphrodite_image)
    contentful_pages.each do |page|
      content = page.fields[:content]
      if content
        if content.include?(elli_image)
          content.gsub(elli_image, aphrodite_image)
          replacement_content = content.gsub(elli_image, aphrodite_image)
          page.update(:content => replacement_content)
          logger.info ("SUCCESS! #{page.title} updated to the following image: #{aphrodite_image}.")
        end
      end
    end
  end
end
