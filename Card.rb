# Card class that encapsulates a card object with suit and face
class Card
	# These are static variables
	@@suitCounter = 0
	@@faceCounter = 0
	@@suits = ["s", "c", "d", "h"]
	@@faces = ["A", "K", "Q", "J", "T", "9", "8", "7", "6", "5", "4", "3", "2"]
		
	def initialize()
		@suit = createSuit()
		@face = createFace()
	end
	 
	 # Getter and setter methods for suit and face variables
	def createSuit()
		s = @@suits[@@suitCounter % 4]
		@@suitCounter += 1
		s
	end
	
	def createFace()
		f = @@faces[@@faceCounter % 13]
		@@faceCounter += 1
		f
	end
	
	def getSuit()
		@suit
	end
	
	def getFace()
		@face
	end
end