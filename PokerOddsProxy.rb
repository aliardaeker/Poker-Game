require './ProxyAPI'

# Network proxy is implemented to access poker odds
class PokerOddsProxy < ProxyAPI
	def makeUrl(cards, board, numberOfPlayers)
		@url = "http://stevenamoore.me/projects/holdemapi?cards=" + cards + "&board=" + board + "&num_players=" + numberOfPlayers
	end
	
	def createObject()
		@odds = @object['odds']
	end
	
	def getOdds(cards, board, numberOfPlayers)
		self.makeUrl(cards, board, numberOfPlayers)
		
		if (self.makeRequest())
			self.createObject()
			@odds
		else
			@odds = -1
		end
	end
end