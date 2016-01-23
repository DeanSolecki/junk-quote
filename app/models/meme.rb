class Meme < ActiveRecord::Base
  validates :image, presence: true
end
