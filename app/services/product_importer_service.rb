class ProductImporterService < ApplicationService
  def call(row)
    product_attributes = yield extract_product_attributes(row:)
    store = yield find_store(row['Store'])
    taxons = yield extract_taxons(row['Taxons'])
    options = yield extract_options(row['Options'])
    properties = yield extract_properties(row['Properties'])

    product = nil

    ActiveRecord::Base.transaction do
      product = yield build_product(product_attributes:, store:)
      product.save!
    end

    yield add_to_product(product, taxons:, options:, properties:)

    add_description(product)
  end

  private

  def find_store(store_name)
    with_rescue do
      Spree::Store.find_by(name: store_name) || Spree::Store.default
    end
  end

  def build_product(product_attributes:, store:)
    with_rescue do
      variant = Spree::Variant.find_by(sku: product_attributes[:sku])
      product = variant.present? ? variant.product : Spree::Product.new(product_attributes)

      product.stores << store unless product.persisted?

      product
    end
  end

  def extract_product_attributes(row:)
    with_rescue do
      {
        sku: row['Sku'],
        name: row['Name'],
        price: row['Price'].to_f,
        shipping_category: Spree::ShippingCategory.find_by(name: 'Default')
      }
    end
  end

  def extract_taxons(taxons)
    with_rescue do
      taxon_pretty_names = taxons.split('|').map(&:strip)

      Spree::Taxon.where(pretty_name: taxon_pretty_names)
    end
  end

  def extract_options(options)
    with_rescue do
      option_names = options.split('|').map(&:strip)

      Spree::OptionType.where(name: option_names)
    end
  end

  def extract_properties(properties)
    with_rescue do
      property_filter_params = properties.split('|').map(&:strip)

      property_filter_params.each_with_object({}) do |property_filter_param, memo|
        key, value = property_filter_param.split(':')
        property = Spree::Property.find_by(filter_param: key)
        memo[property] = value
      end
    end
  end

  def add_to_product(product, taxons:, options:, properties:)
    with_rescue do
      new_taxons_set = taxons.to_a | product.taxons.to_a
      product.taxons = new_taxons_set

      new_options_set = options.to_a | product.option_types.to_a
      product.option_types = new_options_set

      properties.each do |property, value|
        product_property = product.product_properties.find_or_initialize_by(property: property)
        product_property.value = value
        product_property.save!
      end
    end
  end


  def add_description(product)
    with_rescue do
      ru_description = generate_ru_description(product)

      parsed_response = JSON.parse(ru_description)
      product.description = parsed_response["ru"]["description"]
      product.translations.find_or_initialize_by(locale: :ro).update!(description: parsed_response["ro"]["description"])

      product.update!(
        meta_title:       parsed_response.dig("ru", "meta_title"),
        meta_description: parsed_response.dig("ru", "meta_description"),
        meta_keywords:    parsed_response.dig("ru", "meta_keywords")
      )
      product.translations.find_or_initialize_by(locale: :ro).update!(
        meta_title:       parsed_response.dig("ro", "meta_title"),
        meta_description: parsed_response.dig("ro", "meta_description"),
        meta_keywords:    parsed_response.dig("ro", "meta_keywords")
      )

      product.save!
    end
  end

  private

  def generate_ru_description(product)
    prompt = <<~PROMPT
      Напиши привлекательное описание для товара: #{product.name}

      Учти следующие моменты:
      - Это изделие ручной работы от бренда Astor
      - Упомяни материал:
      - Упомяни размеры:
      - Это описание будет храниться в rich text, поэтому используй html теги для форматирования,
      однако это не markdown, поэтому не используй markdown теги.

      Обязательно включи в описание:
      1. Вступительное предложение подчеркивающее ручную работу и качество
      2. Абзац об особенностях конструкции и эргономике:
        - Удобство использования
        - Надежность креплений
        - Качество швов
        - Прочность материалов
      3. Абзац о практическом применении:
        - Для каких пород/размеров животных подходит
        - В каких ситуациях лучше всего использовать
        - Особенности ухода
      4. Заключительный абзац с преимуществами:
        - Долговечность
        - Натуральные материалы
        - Комфорт питомца

      Используй эмоджи где уместно, но не перегружай ими текст.

      Стиль: дружелюбный, профессиональный, вызывающий доверие.
      Длина: 3-4 абзаца, каждый 2-3 предложения.

      Важно: не используй превосходные степени и избегай прямой рекламы.

      также мне нужны мета данные для этого товара, которые будут использоваться для SEO

      Эта информация возможно может быть полезной для SEO:
      магазин называется VetFort, который расположен по адресу ул. Kiev 12 Chisinau, Moldova
      телефон для связи +373 68822758
      email для связи info@vetfort.md

      Пожалуйста, верни ответ в следующем JSON формате:

      {
        "ru": {
          "description": "Полное описание товара на русском (3-4 абзаца с эмоджи, акцент на ручную работу, качество, эргономику)",
          "meta_title": "SEO-заголовок на русском (до 60 символов)",
          "meta_description": "SEO-описание на русском (до 155 символов)",
          "meta_keywords": "ключевые,слова,через,запятую"
        },
        "ro": {
          "description": "Полное описание на румынском (перевод русского описания)",
          "meta_title": "SEO-заголовок на румынском",
          "meta_description": "SEO-описание на румынском",
          "meta_keywords": "cuvinte,cheie,separate,prin,virgulă"
        }
      }

      ВАЖНО: Верни ответ в виде чистого JSON, без маркеров форматирования и без обрамляющих символов markdown или json.
      Не добавляй ```json в начале и ``` в конце.
      Не добавляй никаких пояснений или комментариев.
      Ответ должен начинаться с { и заканчиваться на }.
    PROMPT

    response = OpenaiService.new.complete(prompt)
    response.dig("choices", 0, "message", "content")
  end

end
