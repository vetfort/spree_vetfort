class Spree::SpreeVetfort::LinksController < ApplicationController
  layout 'vetfort_application'

  def index
    @links_component = SpreeVetfort::LinksComponent.new
  end
end
