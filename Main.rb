require './Table.rb'
require './Player.rb'
require './PokerGame.rb'

# Starting point of the program
def main()
	# User is prompted for game specifications
	playersFlag = false
	puts("How many players is there including you? (2 - 8)")
	numberOfPlayers = gets().to_i
	
	if numberOfPlayers > 8 || numberOfPlayers < 2
		playersFlag = true
		puts("\nNumber of players should be between 2 and 8.")
	end
	
	while(playersFlag)
		playersFlag = false
		puts("Enter again:")
		numberOfPlayers = gets().to_i
	
		if numberOfPlayers > 8 || numberOfPlayers < 2
			playersFlag = true
			puts("\nNumber of players should be between 2 and 8.")
		end
	end
	
	puts("\nHow much starting chip is needed?")
	sChip = gets().to_i
	
	players = Array.new
	for i in 0..numberOfPlayers-2
		players[i] = Player.new(sChip)
	end
	
	puts("\nEnter user name: ")
	userName = gets().chomp
	userPlayer = Player.new(sChip)
	userPlayer.setName(userName)
	players << userPlayer
	table = Table.new(players)
	
	pk = PokerGame.new(table, sChip)
end
main()