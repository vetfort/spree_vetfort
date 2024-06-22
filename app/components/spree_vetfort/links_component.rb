# frozen_string_literal: true

class SpreeVetfort::LinksComponent < ViewComponent::Base
  def vetfort_link
    ENV.fetch('VETFORT_LINK', 'https://vetfort.md')
  end

  def instagram_link
    ENV.fetch('INSTAGRAM_LINK', 'https://www.instagram.com/zoo_magazine_vetfort.md/')
  end

  def tiktok_link
    ENV.fetch('TIKTOK_LINK', 'https://www.tiktok.com/@vetfort_zoomagazin?_t=8mwF8K1PDZG')
  end
end
