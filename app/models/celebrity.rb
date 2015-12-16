class Celebrity
	attr_reader :name

	def initialize
		@name = getCelebrityName
	end

  def sanitize
    return self.name.gsub!('_', ' ')
  end

	private

  def getCelebrityName
    celebLength = 7215
    celeb = IO.readlines("#{Rails.root}/lib/seeds/celeblist.txt")[rand(1..celebLength)]
    dirtyString = celeb.to_s
    result = dirtyString.gsub(/\n/, "")
    return result
  end
end
