# Spot It! Mobile
### By: Rachael Wilson

## How to Start the API (in MacOS)
** Very Important to run User login and leaderboard **
1. go to the SpotItMobileAPI folder in the terminal
2. create a vitrual environment using: python3.14 -m venv .venv
3. activate the virtual environment using: source .vevn/bin/activate
4. install the requirements using: pip install -r requirements.txt
5. run the server using: uvicorn main:app


## App Description
This is a mobile version of the card game Spot It! for apple phones. The game modes it has are Singleplayer mode, where you go through all the cards, Multiplayer mode, where you can play with 2 to 8 friends. For the singleplayer mode users will be able to see a global leaderboard if they log in and change their game icons.  


## Singleplayer
Players play a version of The Well game of Spot It! by themselves. The Well is a game mode where you have all Spot It! cards in your hand with one "main card" and try to match the cards in your hand to the main card until you do not have any cards left. After the game ends it displays a picture of my dog, Marco, and he gives you a message if you finish in under five minutes. The game ending page also tells you how fast you completed the game and gived you the options to look at the leaderboard, go back to the homepage, or play singleplayer again. 

## Leaderboard
Leaderboard scores will be from Singleplayer mode only. The leaderboard will both be stored locally and via a FastAPI network to see global scores. Leaderboard scores will be stored under the users username if logged in, if a user is not logged in their scores will only be saved for as long as they have the app open, when they close the app their scores will disappear. If a user logs in mid session then their scores will be added to the global leaderboard. The global leaderboard will be stored on each users device and the database so that they can see the leaderboard from when they last connected to the website that stores information.   

## Change Icons
Users will be able to change the look of their icons. They will be able to change it to a single emoji or character that is not already being used. User's emoji / character preferences will be stored on the website database and users will be able to reset their emojis to the default emojis. 

## Multiplayer
Multiplayer mode will be able to have 2 to 8 players play together, it will also be The Well version of Spot It! Each player will have an equal split of the deck, a pile, depending on the amount of players. There will be a common main card, the player that gets rid of their pile first will be the winner. The game is finished when all players have finished their pile, then a small leaderboard is displayed of who finished first and the time it took them to finish their pile. Then players will have the option to play again or return to the home screen.

## References 
Claude by Anthropic helped with debugging and guideance on this project see AI_USAGE.md for more info.

For help with card generation: http://101computing.net/the-dobble-algorithm/

For help with card generation: https://www.petercollingridge.co.uk/explorations/mathematics-toys-and-games/dobble/

For help with setting up MultiPeer Connectivity: https://youtu.be/85-bxgN42p4?si=e9YweATSJm3P2fE0

For help with MultiPeer Connectivity: https://developer.apple.com/documentation/multipeerconnectivity

