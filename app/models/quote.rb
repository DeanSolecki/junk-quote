class Quote
	attr_reader :text

	def initialize(width)
          @width = width
          with_retries(:max_tries => 10, :base_sleep_seconds => 0.1, :max_sleep_seconds => 1.2) { @text = getQuote }
	end

	private

  def getQuote
    result = false
    quotes = []

    # Loop until returned page has a 'quotes' section.
    while result == false
      res = HTTParty.get('https://en.wikiquote.org/w/api.php?format=json&action=parse&page=' + Celebrity.new.name)
      data = res['parse']['text']['*']
      xpathData = Nokogiri::HTML data
      if xpathData.css("span[id='Quotes']").text != 'Quotes'
        next
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
        next
      end

      tries = 0

      # content validations
      while tries < quotes.length
        selected = quotes[tries]

        if selected == nil
          tries += 1
          next
        elsif selected.match(/[0-9][0-9][0-9][0-9]/)
          tries += 1
          next
        elsif selected[0].match(/[0-9]/) 
          tries += 1
          next
        elsif selected.length > 180
          tries += 1
          next
        end

        result = true
        break
      end
    end

    return fit_text(selected, @width)
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
      txt.pointsize = 36
      txt.stroke = "black"
      txt.fill = "#ffffff"
      txt.font_family = 'helvetica'
      txt.font_weight = Magick::BoldWeight
    }
    metrics = drawing.get_multiline_type_metrics(tmp_image, text)
    (metrics.width < width)
  end
end
