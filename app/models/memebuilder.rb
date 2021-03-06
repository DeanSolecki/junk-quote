require 'base64'
require 'open-uri'

class Memebuilder
  attr_reader :image

  def initialize
    @image = memeCraft
  end

  private 

  def memeCraft
    imageUrl = Image.new.url

    image = Magick::ImageList.new
    urlImage = open(imageUrl)
    image.from_blob(urlImage.read)
    image = image.resize_to_fit(600,600)
    width = image.columns

    quote = Quote.new(width).text
    celebrity = Celebrity.new.sanitize(width)

    topText = Magick::Draw.new
    topText.font_family 'helvetica'
    topText.pointsize = 30
    topText.gravity = Magick::NorthGravity

    topText.annotate(image, 0,0,2,2, quote) {
      self.fill = 'white'
      self.stroke = 'black'
      self.font_weight = Magick::BoldWeight
    }

    bottomText = Magick::Draw.new
    bottomText.font_family = 'helvetica'
    bottomText.pointsize = 30
    bottomText.gravity = Magick::SouthGravity

    bottomText.annotate(image, 0,0,2,2, celebrity) {
      self.fill = 'white'
      self.stroke = 'black'
      self.font_weight = Magick::BoldWeight
    }

    image.write("image.jpg")
    image.destroy!

    return convertToJson(File.open("image.jpg").read)
  end




  def convertToJson(meme)
    data = Base64.strict_encode64(meme)
    File.delete('image.jpg')
    return data
  end

end
