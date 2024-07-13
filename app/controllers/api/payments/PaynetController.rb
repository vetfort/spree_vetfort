class Api::Payments::PaynetController < ApplicationController
  def callback
    render json: { status: 'ok' }
  end
end
