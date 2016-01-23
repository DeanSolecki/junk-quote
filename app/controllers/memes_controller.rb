class MemesController < ApplicationController
  before_action :set_meme, only: [:show, :destroy]

  def grab
    @meme = Meme.first!
    @res = {
      :image => @meme.image
    }
    @meme.destroy
    render json: @res
  end

  def new
    @meme = Meme.new
    respond_with(@meme)
  end

  def create
    @meme = Meme.new(meme_params)
    @meme.save
    respond_with(@meme)
  end

  def destroy
    @meme.destroy
    respond_with(@meme)
  end

  def show
    respond_with(@meme)
  end

  private
  def set_meme
    @meme = Meme.find(params[:id])
  end

  def comment_params
    params.require(:meme).permit(:image)
  end
end
