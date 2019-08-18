class WakesController < ApplicationController
  def index
    render json: {response: "ready"}, status: 200
  end
end
