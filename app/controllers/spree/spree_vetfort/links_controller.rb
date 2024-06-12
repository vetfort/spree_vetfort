class Spree::SpreeVetfort::LinksController < ApplicationController
  def index
    @links_component = SpreeVetfort::LinksComponent.new
  end
end
