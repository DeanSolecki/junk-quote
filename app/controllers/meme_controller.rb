class MemeController < ApplicationController
  def build
    @meme = Meme.new
    @res = {
      :imageUrl => @meme.imageUrl,
      :quote => @meme.quote,
      :celebrity => @meme.celebrity
    }
    render json: @res
  end
end

