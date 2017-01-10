Ali Arda Eker
CS 342 Design Patterns 
Programming Assignment 3
11/13/2016

	Simulation program for poker game is implemented using iterator and proxy paterns
Proxy patern is used for networking in order to retrieve user information from user data api
and odds from Professor's server. Iterator pattern is implemented in table and deck classes
in order to hold card and player objects.

	The main logic of the poker game is implemented in PokerGame class. It performs
basic tasks that a texas hold'em poker match should have. User can choose the number of players,
number of rounds and starting chip. At the first round dealer is choosen randomly then
it shift left by one person in each round. Players are assigned random game style and they 
move according to this.

	Database class is implemented to create a json file which holds players information.
This class is singleton. At the end of the game all the information across multiple rounds 
are printed on the screen using this database.

	Extra Credit: UserDataProxy class is implemented to access user data api for
getting random names for players. It inherits ProxyAPI abstrat class.	

	