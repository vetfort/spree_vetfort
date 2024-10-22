class Spree::SpreeVetfort::LinksController < ApplicationController
  layout 'spree_vetfort/vetfort_application'

  def index
    @links_component = SpreeVetfort::LinksComponent.new
  end
end
