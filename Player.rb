require './UserDataProxy.rb'

# Player class for defining each player by name, game style, money and holding cards
class Player
	def initialize(m)
		@userPlayer = false
		@dealer = false
		@name = createName()
		@playStyle = createStyle()
		@holeCard1 = ""
		@holeCard2 = ""
		@money = m
		@inGame = true
	end
	
	# Setter and getter methods for player variables
	def setName(n)
		@name = n
		@userPlayer = true
		@playStyle = -1
	end
	
	def getName()
		@name
	end
	
	def userPlayer?
		@userPlayer
	end
	
	def createName()
		proxy = UserDataProxy.new()
		data = proxy.getUserData()
	end
	
	def createStyle()
		s = Random.rand(1...5)
	end
	
	def getStyle()
		@playStyle
	end
	
	def isDealer?
		@dealer
	end
	
	def setDealer()
		@dealer = true
	end
	
	def unDealer()
		@dealer = false
	end
	
	def setHoleCards(c1, c2)
		@holeCard1 = c1
		@holeCard2 = c2
	end
	
	def getHoleCards()
		array = [@holeCard1, @holeCard2]
	end
	
	def getMoney()
		@money
	end
	
	def changeMoney(m)
		@money = @money + m
	end
	
	def setInGame(flag)
		@inGame = flag
	end
	
	def isInGame?
		@inGame
	end
end