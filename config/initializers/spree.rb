Rails.application.config.after_initialize do
  Rails.application.config.spree_backend.main_menu.add(
    Spree::Admin::MainMenu::ItemBuilder
      .new('offline_vetfort', Spree::Core::Engine.routes.url_helpers.new_admin_spree_vetfort_offline_path)
      .with_icon_key('bag-check.svg')
      .build
  )

  Rails.application.config.spree_backend.main_menu.add(
    Spree::Admin::MainMenu::ItemBuilder
      .new('import_vetfort', Spree::Core::Engine.routes.url_helpers.new_admin_spree_vetfort_import_path)
      .with_icon_key('arrow-right-square.svg')
      .build
  )

  # Spree::Frontend::Config[:layout] = 'vetfort_application'
end
