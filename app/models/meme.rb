require 'base64'
require 'open-uri'

class Meme
  attr_reader :image

  def initialize
    @image = memeCraft
  end

  private 

  def memeCraft
    imageUrl = getImageUrl
    quote = fit_text(getQuote, 600)
    celebrity = getSanitizedCelebrity

    image = Magick::ImageList.new
    urlImage = open(imageUrl)
    image.from_blob(urlImage.read)
    image = image.resize_to_fit(600,600)

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

    return convertToJson(File.open("image.jpg").read)
  end

  def getImageUrl
    # Config yahoo api.
    YBoss::Config.instance.oauth_key = ENV['YBOSS_KEY']
    YBoss::Config.instance.oauth_secret = ENV['YBOSS_SECRET']
    rand = Random.new

    # Grab a random noun from list and query image search with it.
    noun = IO.readlines("#{Rails.root}/lib/seeds/nounlist.txt")[rand(1..2327)]
    res = YBoss.images('q' => noun, 'format' => 'json', 'count' => '1', 'start' => rand(1..300).to_s, 'dimensions' => 'medium')

    # Make sure image doesn't return error code and is either a jpg or png.
    # Will make another API call if all 35 results are bad. (Let's hope not!)
    stillLooking = true
    count = 0

    while stillLooking
      if count >= 34
        res = YBoss.images('q' => noun, 'format' => 'json', 'count' => '1', 'start' => rand(1..300).to_s, 'dimensions' => 'medium')
        count = 0
      end

      imgRes = HTTParty.get(res.items[count].url)

      if imgRes.response.is_a?(Net::HTTPOK)
        stillLooking = false
      else
        stillLooking = true
      end
    end

    # Return successful image url
    @imageUrl = res.items[count].url
  end

  def getQuote
    result = false
    quotes = []

    # Loop until returned page has a 'quotes' section.
    while result == false
      res = HTTParty.get('https://en.wikiquote.org/w/api.php?format=json&action=parse&page=' + getCelebrity)
      data = res['parse']['text']['*']
      xpathData = Nokogiri::HTML data
      if xpathData.css("span[id='Quotes']").text == 'Quotes'
        result = true
      else
        result = false
      end

      # Parse quotes
      rawQuotes = xpathData.xpath("//ul/li").map{|data_node| data_node.text}
      rawQuotes.each do |quote|
        if match = quote.match(/(.+?)\n\n/)
          rawQuote = $1
          strippedQuote = rawQuote.gsub(/\"/, "'")
          quotes << strippedQuote
        end
      end

      # Verify quotes is not empty
      if quotes.length < 1
        result = false
      else
        result = true
      end

      selected = quotes[rand(0..(quotes.length))]

      if selected == nil
        result = false
      elsif selected[0].match(/[0-9]/) 
        result = false
      end
    end

    return selected
  end

  def getCelebrity
    celebLength = 7215
    celeb = IO.readlines("#{Rails.root}/lib/seeds/celeblist.txt")[rand(1..celebLength)]
    dirtyString = celeb.to_s
    result = dirtyString.gsub(/\n/, "")
    return result
  end

  def getSanitizedCelebrity
    return getCelebrity.gsub!('_', ' ')
  end

  def convertToJson(meme)
    data = Base64.strict_encode64(meme)
    return data
  end

  def fit_text(text, width)
    separator = ' '
    line = ''

    if not text_fit?(text, width) and text.include? separator
      i = 0
      text.split(separator).each do |word|
        if i == 0
          tmp_line = line + word
        else
          tmp_line = line + separator + word
        end

        if text_fit?(tmp_line, width)
          unless i == 0
            line += separator
          end
          line += word
        else
          unless i == 0
            line +=  '\n'
          end
          line += word
        end
        i += 1
      end
      text = line
    end
    text
  end

  def text_fit?(text, width)
    tmp_image = Magick::Image.new(width, 500)
    drawing = Magick::Draw.new
    drawing.annotate(tmp_image, 0, 0, 0, 0, text) { |txt|
      txt.gravity = Magick::NorthGravity
      txt.pointsize = 32
      txt.stroke = "black"
      txt.fill = "#ffffff"
      txt.font_family = 'helvetica'
      txt.font_weight = Magick::BoldWeight
    }
    metrics = drawing.get_multiline_type_metrics(tmp_image, text)
    (metrics.width < width)
  end
end
