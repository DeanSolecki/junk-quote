class MemesController < ApplicationController
  before_action :set_meme, only: [:show, :update, :destroy]

  # GET /memes
  # GET /memes.json
  def index
    @memes = Meme.all

    render json: @memes
  end

  # GET /memes/1
  # GET /memes/1.json
  def show
    render json: @meme
  end

  # POST /memes
  # POST /memes.json
  def create
    @meme = Meme.new(meme_params)

    if @meme.save
      render json: @meme, status: :created, location: @meme
    else
      render json: @meme.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /memes/1
  # PATCH/PUT /memes/1.json
  def update
    @meme = Meme.find(params[:id])

    if @meme.update(meme_params)
      head :no_content
    else
      render json: @meme.errors, status: :unprocessable_entity
    end
  end

  # DELETE /memes/1
  # DELETE /memes/1.json
  def destroy
    @meme.destroy

    head :no_content
  end

  private

    def set_meme
      @meme = Meme.find(params[:id])
    end

    def meme_params
      params.require(:meme).permit(:image)
    end
end
