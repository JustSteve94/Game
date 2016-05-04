# MQTT Server
require "socket"

SIZE = 1024

class Server
  def initialize( port, ip )
    @server = TCPServer.open( ip, port )
    @connections = Hash.new
    @topics = Hash.new
    @clients = Hash.new
    @score = Hash.new
    @answers = Hash.new
    @connections[:answers] = @answers
    @connections[:server] = @server
    @connections[:topics] = @topics
    @connections[:clients] = @clients
    @connections[:score] = @score
    @connections[:answers] = {'countries1' => 'india', 
    						'countries2' => 'egypt', 
    						'countries3' => 'peru', 
    						'things1' => 'sunglasses', 
    						'things2' => 'dice', 
    						'things3' => 'train'}
    @connections[:topics] = {'countries' => [], 'things' => []}
    run
  end

  def run
    loop {
      Thread.start(@server.accept) do | client |
      	client.puts 'Do you wanna play a game? (yes/no)'
      	answ = client.gets.chomp.to_sym
      	if answ == 'no'
      		Thread.kill self
      	end
      	accounts(client)
      	nick_name = @connections[:clients].key(client)
      	topic = topics(client, nick_name)
      	game(client, nick_name, topic)
        listen_user_messages( nick_name, client )
      end
    }.join
  end

  def accounts(client)
  	client.puts 'Enter your nick_name: '
  	nick_name = client.gets.chomp.to_sym
  	@connections[:clients].each do |other_name, other_client|
          if nick_name == other_name || client == other_client
            client.puts "This username already exist"
            Thread.kill self
        end
    end
    puts "#{nick_name} #{client.peeraddr[1]}"
    @connections[:clients][nick_name] = client
    client.puts "Connection established\n"  
  end

  def topics(client, nick_name)
  	client.puts "Select one of the next topics:"
  	@connections[:topics].each_key {|key| client.puts " - #{key}"}
  	topic = client.gets.chomp
  	@connections[:topics][topic].push(nick_name)
  	puts @connections[:topics][topic]
  	puts "control"
  	while @connections[:topics][topic].length < 1 do
  		client.puts "Please wait 10 sec for one more player."
  		sleep 10
  	end
  	return topic
  end

  def game(client, nick_name, topic)
  	point = 0
  	win_points = 0
	draw = false
	win_name = ''
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
	while @connections[:score].length < 1 do
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
  end

  def sendImage(client, name)
  	file = File.open("#{name}.png", 'rb')
      while chunk = file.read(SIZE)
        client.write(chunk)
      end
    file.close
    client.write "jump"+" "*1020
    client.puts "\nAnswer: "
  end

  def listen_user_messages( username, client )
    loop {
      msg = client.gets.chomp
      @connections[:clients].each do |other_name, other_client|
        unless other_name == username
          other_client.puts "#{username.to_s}: #{msg}"
        end
      end
    }
  end

end

Server.new( 3000, "localhost" )

# Publish example
# MQTT::Client.connect('localhost') do |c|
#     file = File.open("c_brazil.png", 'rb')
#     message = file.read(SIZE)
#     file.close
#  	c.publish('country', message)
# end