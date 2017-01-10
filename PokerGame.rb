require './Player.rb'
require './Table.rb'
require './Card.rb'
require './Deck.rb'
require './PokerOddsProxy.rb'
require './Database.rb'

# Main logic of a poker game is implemented in this class
class PokerGame
	@@playersArray = Array.new()
	
	def initialize(table, chip)
		@proxy = PokerOddsProxy.new
		@table = table
		@deck
		@chip = chip
		@cardsOpened = ""
		@winnerSet = false
		gameBegin()
	end
	
	def gameBegin()
		createHash()
		dealerFlag = false
		
		puts("\nHow many rounds do you wish?")
		rounds = gets().to_i
		puts ("\nGame begins. \nBlind is 5 chips.")
		
		# Game loop is here
		for i in 0..rounds-1
			if (!dealerFlag)
				@table.chooseDealer()
				@table.arrangeTable()
				dealerFlag = true
			else
				@table.setDealer()
			end

			dealCards()
			firstRound()			
			flop()
			
			if (!@winnerSet)
				turn()
			end
			if (!@winnerSet)
				river()
			end
			if (!@winnerSet)
				winner()
			end
			
			Database.writeJson(@@playersArray)
			Database.print()
			@table.setMoneyOnTableZero
		end
		
		puts("Game is done.")
	end
	
	# First we deal the cards randomly
	def dealCards()
		cards = Array.new
		for i in 0..51
			cards[i] = Card.new
		end
		@deck = Deck.new(cards)
	
		@table.cycle(1) { |p|
			index = Random.rand(0...@deck.getLength)
			c1 = @deck.getCard(index)
			@deck.deleteAt(index)
		
			index = Random.rand(0...@deck.getLength)
			c2 = @deck.getCard(index)
			@deck.deleteAt(index)
	
			p.setHoleCards(c1, c2)
			gamesPlayed(p)
			
			if (p.userPlayer?)
				puts("Your cards are " + c1.getFace + c1.getSuit + " and " + c2.getFace + c2.getSuit + ".")
				if (p.isDealer?)
					puts("\nYou are the dealer in this round.")
					p.changeMoney(-5)
					@table.raiseMoneyOnTable(5)
					puts("You put 5 chips because you have the blind bet. You got " + p.getMoney.to_s + " chips left.\n")
				end
			elsif (p.isDealer?)
				puts ("\n" + p.getName + " is dealer in this round.")
				puts(p.getName + " puts 5 chips as blind bet.\n\n")
				p.changeMoney(-5)
				@table.raiseMoneyOnTable(5)
			end
		}
	end

	# Users can choose to fold, bet or check
	def firstRound()
	answer = ""
	counter = 0
	
	@table.cycle(1) { |p|
		if (p.userPlayer? && !p.isDealer?)
			puts("\nMoney on the table is " + @table.getMoneyOnTable().to_s)
			
			if (counter < @table.getNumberOfPlayers.to_i-1)
				puts("See, fold or check?")
				a = gets().chomp()
			else
				puts("See or fold?")
				a = gets().chomp()
			end
				
			if (a.downcase == "see")
				puts("You put 5 chips.")
				p.changeMoney(-5)
				@table.raiseMoneyOnTable(5)			
			elsif (a.downcase == "check")
				answer = "check"
			elsif (a.downcase == "fold")
				lost(p)
				folded(p)
				puts("You left the game.")
				p.setInGame(false)
			else
				abort("Wrong input!")
			end
		elsif (!p.userPlayer? && !p.isDealer?)
			counter = counter + 1
			if (p.getStyle > 1)
				puts("\n" + p.getName + " sees and puts 5 chips.")
				p.changeMoney(-5)
				@table.raiseMoneyOnTable(5)
			else
				lost(p)
				folded(p)
				puts("\n" + p.getName + " folds and lefts the game.")
				p.setInGame(false)
			end
		end
		p.unDealer()
	}
	
		if (answer == "check" && @table.getNumberOfPlayers.to_i > 1)
			puts("\nMoney on the table is " + @table.getMoneyOnTable().to_s)
			puts("See or fold?")
			a = gets().chomp()
		
			if (a.downcase == "see")
				@table.select { |p|
					if p.userPlayer? 
						p.changeMoney(-5)
						puts("You saw and put 5 chips. You have "+ p.getMoney.to_s + " chips left.")	
						@table.raiseMoneyOnTable(5)
					end
				}
			elsif (a.downcase == "fold")
				puts("You left the game.")
				@table.select { |p|
					if p.userPlayer? 
						lost(p)
						folded(p)
						p.setInGame(false)
					end
				}	
			else
				abort("Wrong input!")
			end
		end
	end

	# This method is called after 3 cards are opened
	def flop()
		puts("\nMoney on the table is " + @table.getMoneyOnTable().to_s)
		@cardsOpened = @deck.theFlop()
		puts ("3 cards are opened on the table: " + @cardsOpened + "\n\n")
		cycle()
	end
	
	# Thşs method is called after 4th card is opened
	def turn()
		card = @deck.theTurnAndRiver()
		@cardsOpened = @cardsOpened + card
		puts ("\n" + card + " opened new. " + @cardsOpened + " are on the table now.\n\n")	
		cycle()
	end
	
	# This is called after all the cards are opened
	def river()
		card = @deck.theTurnAndRiver()
		@cardsOpened = @cardsOpened + card
		puts ("\n" + card + " is the last card opened. " + @cardsOpened + " are on the table now.\n\n")	
		cycle()
	end
	
	# Main logic is here. The game cycles in this method
	def cycle()
		@table.cycle(1) { |p|
			if (p.isInGame?)
				puts(p.getName() + " is in the game.")
			end
		}
		puts()
		
		answer = ""
		counter = 0
		counter2 = 0
		moneyPut = 0
		mFlag = false
		
		@table.cycle(1) { |p|
			# If a player is still in the game, he or she can choose a actions
			if (p.isInGame? && @table.getNumberOfPlayers.to_i > 1)
				# User player is here
				if(p.userPlayer?)
					if (counter == 0 || (counter != 0 && moneyPut == 0))
						puts("Raise or check?")
						a = gets().chomp().downcase
					elsif (counter != 0 && moneyPut != 0)
						puts("See or fold?")
						a = gets().chomp().downcase
					else
						abort("Aborted in turn.")
					end
				
					if (a == "raise")
						mFlag = true
						puts("How many chips do you want to put?")
						moneyPut = gets().chomp().to_i
						puts("You put " + moneyPut.to_s + " chips." )
					
						p.changeMoney(-moneyPut)
						puts("You got " + p.getMoney.to_s + " chips left.")
						@table.raiseMoneyOnTable(moneyPut)
					
					elsif (a == "check")
						answer = "check"
						
					elsif (a == "see")
						puts("You put " + moneyPut.to_s + " chips.")
						p.changeMoney(-moneyPut)
					
						puts("You got " + p.getMoney.to_s + " chips left.")
						@table.raiseMoneyOnTable(moneyPut)
					elsif (a == "fold")
						puts("You left the game.")
					
						@table.select { |p|	
							if p.userPlayer? 
								lost(p)
								folded(p)
								p.setInGame(false)
							end
						}	
					else
						abort("Wrong input.")
					end
				# Bots are move here according to their game style
				else
					counter = counter + 1
					c1 = p.getHoleCards[0]
					c2 = p.getHoleCards[1]
					odds = @proxy.getOdds(c1.getFace + c1.getSuit + c2.getFace + c2.getSuit, @cardsOpened, @table.getNumberOfPlayers())
			
					if (p.getStyle() == 4)
						if ((odds > 0.2 || answer == "check" || counter2 == 0) && p.getMoney > 10)
							if(!mFlag)
								moneyPut = 10
								mFlag = true
								p.changeMoney(-10)
								puts("\n" + p.getName + " puts 10 chips. Got " + p.getMoney.to_s + " chips left.")	
								
								@table.raiseMoneyOnTable(10)
								puts("Money on the table is " + @table.getMoneyOnTable().to_s + "\n")
							else
								p.changeMoney(-moneyPut)
								puts("\n" + p.getName + " puts " + moneyPut.to_s + " chips. Got " + p.getMoney.to_s + " chips left.")
														
								@table.raiseMoneyOnTable(moneyPut)
								puts("Money on the table is " + @table.getMoneyOnTable().to_s + "\n")	
							end
						else
							lost(p)
							folded(p)
							puts("\n" + p.getName + " folded.")
							p.setInGame(false)
						end	
					
					elsif (p.getStyle() == 3)
						if ((odds > 0.2 || answer == "check" || counter2 == 0) && p.getMoney > 10)
							if(!mFlag)
								moneyPut = 5
								mFlag = true
								p.changeMoney(-5)
								puts("\n" + p.getName + " puts 5 chips. Got " + p.getMoney.to_s + " chips left.")	
								
								@table.raiseMoneyOnTable(5)
								puts("Money on the table is " + @table.getMoneyOnTable().to_s + "\n")
							else
								p.changeMoney(-moneyPut)
								puts("\n" + p.getName + " puts " + moneyPut.to_s + " chips. Got " + p.getMoney.to_s + " chips left.")
								
								@table.raiseMoneyOnTable(moneyPut)
								puts("Money on the table is " + @table.getMoneyOnTable().to_s + "\n")
							end
						else
							lost(p)
							folded(p)
							puts("\n" + p.getName + " folded.")
							p.setInGame(false)
						end	
					
					elsif (p.getStyle() == 2)
						if ((odds > 0.6 || answer == "check" || counter2 == 0) && p.getMoney > 10)
							if(!mFlag)
								moneyPut = 10
								mFlag = true
								p.changeMoney(-10)
								puts("\n" + p.getName + " puts 10 chips. Got " + p.getMoney.to_s + " chips left.")
								
								@table.raiseMoneyOnTable(10)
								puts("Money on the table is " + @table.getMoneyOnTable().to_s + "\n")
							else
								p.changeMoney(-moneyPut)
								puts("\n" + p.getName + " puts " + moneyPut.to_s + " chips. Go t" + p.getMoney.to_s + " chips left.")
								
								@table.raiseMoneyOnTable(moneyPut)
								puts("Money on the table is " + @table.getMoneyOnTable().to_s + "\n")
							end
						else
							lost(p)
							folded(p)
							puts("\n" + p.getName + " folded.")
							p.setInGame(false)
						end	
					
					elsif (p.getStyle() == 1)
						if ((odds > 0.6 || answer == "check" || counter2 == 0) && p.getMoney > 10)
							if(!mFlag)
								moneyPut = 5
								mFlag = true
								p.changeMoney(-5)
								puts("\n" + p.getName + " puts 5 chips. Got " + p.getMoney.to_s + " chips left.")
								
								@table.raiseMoneyOnTable(5)
								puts("Money on the table is " + @table.getMoneyOnTable().to_s + "\n")
							else
								p.changeMoney(-moneyPut)
								puts("\n" + p.getName + " puts " + moneyPut.to_s + " chips. Got " + p.getMoney.to_s + " chips left.")
								
								@table.raiseMoneyOnTable(moneyPut)
								puts("Money on the table is " + @table.getMoneyOnTable().to_s + "\n")
							end
						else
							lost(p)
							folded(p)
							puts("\n" + p.getName + " folded.")
							p.setInGame(false)
						end
					else
						won(p)
						puts ("You won " + table.getMoneyOnTable() + " chips.")
						winnerSet = true
					end
				end
			elsif (@table.getNumberOfPlayers.to_i == 1)
				winnerSet = true
			end
			
			 counter2 += 1
		}
		
		if (answer == "check" && @table.getNumberOfPlayers != 1)
			puts("\nMoney on the table is " + @table.getMoneyOnTable().to_s)
			puts("See or fold?")
			a = gets().chomp().downcase
				
			if (a == "see")
				@table.select { |p|	
					if p.userPlayer? 
						p.changeMoney(-moneyPut)
						@table.raiseMoneyOnTable(moneyPut)
						puts("You put " + moneyPut.to_s + " chips.")
					end
				}
			elsif (a == "fold")
				puts("You left the game.")
				@table.select { |p|	
					if p.userPlayer? 
						lost(p)
						folded(p)
						p.setInGame(false)
					end
				}
			else
				abort("Enter 'see' or 'fold'.")
			end
		end
		
		if (@table.getNumberOfPlayers() == 1)
			@table.select { |p|	
				c1 = p.getHoleCards[0]
				c2 = p.getHoleCards[1]
				
				if p.userPlayer? 
					won(p)
					puts("Congragulations! You won the game with " + c1.getFace + c1.getSuit + " and " + c2.getFace + c2.getSuit) 
					puts("You got " + @table.getMoneyOnTable() + " chips.")
					p.changeMoney(@table.getMoneyOnTable())
					winnerSet = true
				else
					won(p)
					puts("\n" + p.getName + " won the game with " + c1.getFace + c1.getSuit + " and " + c2.getFace + c2.getSuit) 
					puts("Got " + @table.getMoneyOnTable().to_s + " chips.")
					p.changeMoney(@table.getMoneyOnTable())
					winnerSet = true
				end
			}
		end
	end
	
	# This method is used for calling the winner
	def winner()
		winner =  ""
		maxOdd = 0
		
		@table.cycle(1) { |p|
			if (p.isInGame?)
				c1 = p.getHoleCards[0]
				c2 = p.getHoleCards[1]
				odds = @proxy.getOdds(c1.getFace + c1.getSuit + c2.getFace + c2.getSuit, @cardsOpened, @table.getNumberOfPlayers())
			
				if (odds > maxOdd)
					maxOdd = odds
					winner = p.getName()
				end
			end
		}
		
		@table.cycle(1) { |p|
			if (p.isInGame?)
				c1 = p.getHoleCards[0]
				c2 = p.getHoleCards[1]
					
				if (p.getName == winner)	
					if p.userPlayer? 
						won(p)
						puts("Congragulations! You won the game with " + c1.getFace + c1.getSuit + " and " + c2.getFace + c2.getSuit) 
						puts("You got " + @table.getMoneyOnTable().to_s + " chips.")
						p.changeMoney(@table.getMoneyOnTable())
						winnerSet = true
					else
						won(p)
						puts("\n" + p.getName + " won the game with " + c1.getFace + c1.getSuit + " and " + c2.getFace + c2.getSuit) 
						puts("Got " + @table.getMoneyOnTable().to_s + " chips.")
						p.changeMoney(@table.getMoneyOnTable())
						winnerSet = true
					end
				else			
					puts("\n" + p.getName + " lost at final round. Got " + c1.getFace + c1.getSuit + " and " + c2.getFace + c2.getSuit)
					lost(p)
				end
			end
		}
	end
	
	# Creates an empty hash for database class
	def createHash()
		counter = 0
		
		@table.cycle(1) { |p|
			player = {name: p.getName(), folds: 0, wins: 0, loses: 0, gamesPlayed: 0}
			@@playersArray[counter] = player
			counter = counter + 1
		}
	end

	# Modifies hash objects
	def folded(p)
		@@playersArray.each() do |pHash|
			if p.getName() == pHash[:name]
				pHash[:folds] = pHash[:folds] + 1
			end
		end
	end

	def won(p)
		@@playersArray.each() do |pHash|
			if p.getName() == pHash[:name]
				pHash[:wins] = pHash[:wins] + 1
			end
		end
	end
	
	def lost(p)
		@@playersArray.each() do |pHash|
			if p.getName() == pHash[:name]
				pHash[:loses] = pHash[:loses] + 1
			end
		end
	end
	
	def gamesPlayed(p)
		@@playersArray.each() do |pHash|
			if p.getName() == pHash[:name]
				pHash[:gamesPlayed] = pHash[:gamesPlayed] + 1
			end
		end
	end
end