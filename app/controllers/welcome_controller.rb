class WelcomeController < ApplicationController
  def index
    render json: {message: "Welcome to the Song Explorer API"}
  end
end
