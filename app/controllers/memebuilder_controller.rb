class MemebuilderController < ApplicationController
  def build
    @meme = Memebuilder.new
    @res = {
      :image => @meme.image
    }
    render json: @res
  end
end

