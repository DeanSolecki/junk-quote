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
    result = nil
    celebLength = 7215
    while result == nil
      celeb = IO.readlines("#{Rails.root}/lib/seeds/celeblist.txt")[rand(1..celebLength)]
      dirtyString = celeb.to_s
      result = dirtyString.gsub(/\n/, "")
    end
    return result
  end
end
