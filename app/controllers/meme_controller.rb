class MemeController < ApplicationController
  def build
    @meme = Meme.new
    @res = {
      :imageUrl => @meme.imageUrl,
      :quote => @meme.quote,
      :celebrity => @meme.celebrity
    }
    format.js { render json: => { @res.to_json }}
  end
end

