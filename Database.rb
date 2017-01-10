require 'json'

# Singleton Database class which writes into a json file
module Database
	class << self
		# For writing to a json file
		def writeJson(pArray)
			File.open("database.json", "w") do |f|
				pArray.each() do |pHash|
					f << pHash.to_json
					f << "\n"
				end
			end
		end
		
		# For printing from a json file to the console
		def print
			puts()
			File.open('database.json').each do |line|
				hash = JSON.parse(line)
				puts(hash['name'] + " has " + hash['folds'].to_s + " folds " + hash['wins'].to_s + " wins " + hash['loses'].to_s + " loses in " + hash['gamesPlayed'].to_s + " games.")
			end
		end
	end
end