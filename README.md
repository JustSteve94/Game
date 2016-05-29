Network Programming Game
========================


Hey! Here is my first Network Programming **Game** which rely on the BSD socket API. This is a multiplayer game where each player plays 3 rounds. 
In next sequence diagram you can see how user interacts with game:

![alt text](https://github.com/JustSteve94/Game/blob/master/img/diagram.PNG "Sequence Diagram")

Breaking in parts
------------------
* After client connects to server, player is asked if he/she wants to play. If players says no, server says **Goodbye** and connection between them and client are immediately closed. If player says yes then he proceed to next step. If player tries to write something else then yes or no, he is asked again the same question.

```ruby
Thread.start(@server.accept) do | client |
  	client.puts 'Do you wanna play a game? (yes/no)'
  	answ = client.gets.chomp
  	if answ == 'no'
  		client.puts 'Goodbye!'
  		Thread.kill self
  	elsif answ == 'yes'
```

* Player is asked to write a Nickname which is checked by server if it's not repeating and proceeds to the next step, otherwise server says that the nickname alredy exists and asks player to enter new nickname.

```ruby
client.puts 'Enter your nickname: '
  	nick_name = client.gets.chomp
  	while @connections[:clients].has_key?(nick_name) do
  		client.puts 'This nickname already exist'
  		client.puts 'Enter your nickname: '
  		nick_name = client.gets.chomp
   	end
```

* Player nickname and connection is printed on server screen. Server attaches his nickname to his TCP connection and adds them in Hash @connections[:clients]. Server acknowledges client that connection is established.

```ruby
puts "#{nick_name} #{client.peeraddr[1]}"
    @connections[:clients][nick_name] = client
    client.puts "Connection established\n\n"  
```
* Player is asked to select one of the next topics which are stored in hash @connections[:topics]. When player selected the topic he is added in hash @connections[:topics][topic] to selected topic. After server checks how many players are in selected topic, if there are at least 2 players game starts otherwise player is asked to wait.

```ruby
client.puts "Select one of the next topics:"
  	@connections[:topics].each_key {|key| client.puts " - #{key}"}
  	topic = client.gets.chomp
  	@connections[:topics][topic].push(nick_name)
  	puts @connections[:topics][topic]
  	while @connections[:topics][topic].length < 2 do
  		client.puts "Please wait 10 sec for one more player."
  		sleep 10
  	end
```

* Players are announced that games starts in 5 seconds. When game starts they are annouced that first round started and each player receive image where they must answer regarding to topic that has been chosen, after players continue to next round till the last one, the third one. All players score is stored in hash @connections[:score]. When all players finished results are announced(Draw/Winner/Players score), otherwise player is asked to waint until all players finishes game.

```ruby
client.puts 'Game starts in 5 sec'
  	sleep 5
  	1.upto(3) do |round|
	  	client.puts "Round ##{round}"
	  	name = "#{topic}#{round}"
	  	sendImage(client, name)
	    answ = client.gets.chomp
	    point += 1 if answ == @connections[:answers][name]
	end
    @connections[:score][nick_name] = point
	while @connections[:score].length < 2 do
		client.puts 'Wait 5 sec until other player finishes.'
		sleep 5
	end
	@connections[:score].each do |name, points|
		client.puts "#{name}: #{points}"
		if win_points <= points
			if win_points == points
				draw = true
			end
			win_points = points
			win_name = name
		end
	end
	if draw
		client.puts "Draw"
	else 
		client.puts "Winner: #{win_name}" 
	end
```