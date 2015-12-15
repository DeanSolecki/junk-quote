class MemeController < ApplicationController
  def build
    @meme = Meme.new
    @res = {
      :image => @meme.image
    }
    render json: @res
  end
end

