class CelebBuilder
  def initialize
  end

  def buildList
    letters = %w(A B C D E-F G H I-J K L M N-O P Q-R S T-V W-Z)
    names = []

    letters.each do |letter|
      res = HTTParty.get('https://en.wikiquote.org/w/api.php?format=json&action=parse&page=List_of_people_by_name,_' + letter)
      data = res['parse']['text']['*']
      xpathData = Nokogiri::HTML data
      rawData = xpathData.xpath("//li/a").map{|data_node| data_node['href']}
      rawData.each do |link|
        if match = link.match(/\/wiki\/(.+)/)
          open("#{Rails.root}/lib/seeds/celeblist.txt", 'a') do |f|
            f.puts $1
          end
        end
      end
    end
    return true
  end
end
