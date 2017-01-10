# Holds player objects in an array and implements enumerable module
class Table
	include Enumerable
	@@counter = 1
	
	def initialize(players)
		@cardsOnTable = ""
		@players = players
		@totalMoneyOnTable = 0
	end
	
	def each(&block)
		@players.each do |p|
			block.call(p)
		end
	end
	
	# randomly chooses a dealer
	def chooseDealer()
		index = Random.rand(0...@players.length)
		@players[index].setDealer()
	end 
	
	def setDealer()
		@players[@@counter % 5].setDealer()
		@@counter += 1
	end
	
	# returns number of players in the game
	def getNumberOfPlayers()
		counter = 0
		
		@players.each do |p|
			if p.isInGame?
				counter = counter + 1
			end
		end
		
		counter.to_s
	end
	
	def raiseMoneyOnTable(m)
		@totalMoneyOnTable = @totalMoneyOnTable + m
	end
	
	def setMoneyOnTableZero()
		@totalMoneyOnTable = 0
	end
	
	def getMoneyOnTable
		@totalMoneyOnTable
	end
	
	# arranges table according to the dealer
	def arrangeTable()
		counter = 0
		tmpCounter = 0
		
		@players.each do |p|
			if p.isDealer?
				break
			end
			counter += 1
		end
		
		tmp = []		
		for i in counter..counter+@players.length-1
			tmp[tmpCounter] = @players[i % @players.length]
			tmpCounter += 1
		end
		@players = tmp
	end
end