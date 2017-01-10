# Deck class holds 52 cards and implements enumerable module
class Deck
	include Enumerable
		
	def initialize(cards)
		@cards = cards
	end
	
	# Getter ans setter methods
	def each(&block)
		@cards.each do |c|
			block.call(c)
		end
	end
	
	def getLength()
		@cards.length
	end
	
	def getCard(index)
		@cards[index]
	end
	
	def deleteAt(index)
		@cards.delete_at(index)
	end
	
	# 3 cards are generated randomly
	def theFlop()
		index = Random.rand(0...@cards.length)
		c1 = @cards[index]
		@cards.delete_at(index)
		
		index = Random.rand(0...@cards.length)
		c2 = @cards[index]
		@cards.delete_at(index)
		
		index = Random.rand(0...@cards.length)
		c3 = @cards[index]
		@cards.delete_at(index)
		
		flop = c1.getFace + c1.getSuit + c2.getFace + c2.getSuit + c3.getFace + c3.getSuit
	end
	
	# 1 card is generated randomly
	def theTurnAndRiver()
		index = Random.rand(0...@cards.length)
		c = @cards[index]
		@cards.delete_at(index)
		c = c.getFace + c.getSuit
	end
end