# MQTT Client
require "socket"

SIZE = 1024

class Client
  	def initialize( server )
	    @server = server
	    @request = nil
	    @response = nil
	    listen
	    send
	    @request.join
	    @response.join
  	end

  	def listen
	    @response = Thread.new do
	      loop {
	        msg = @server.gets.chomp
	        if msg.include? "Round"
	        	puts msg
	        	receiveImage
	        	next
			end
	        puts "#{msg}"
	        if msg == 'This username already exist'
	        	exit
	        end
	      }
	    end
  	end

	def send
	    puts "Enter the username:"
	    @request = Thread.new do
	      loop {
	        msg = $stdin.gets.chomp
	        @server.puts( msg )
	        if msg == 'goodbye'
	        	exit
	        end
	      }
	    end
  	end

	def receiveImage
		if File.exist?('img.png')
			File.delete('img.png')
		end
		puts 'pas'
		img = File.new("img.png", "wb")
		while chunk = @server.readpartial(SIZE)
			if chunk.include? "jump"
    			chunk.delete "jump"
    			img.write(chunk.squeeze)
    			break
    		end
    		puts 'pas'
    		img.write(chunk)
        end
	    img.close
	    system 'Start "" "img.png"'
	    system 'cls'
	end
end

server = TCPSocket.open( "localhost", 3000 )
Client.new( server )

# Subscribe example
# MQTT::Client.connect('localhost') do |c|
#   # If you pass a block to the get method, then it will loop
#   c.get('country') do |topic,message|
#   	if File.exist?('img.jpg')
#   		File.delete('img.jpg')
#   	end
#  	tmp = File.new('img.jpg', "wb")
#  	tmp << message
#  	tmp.close
#     system 'Start "" "img.jpg"'
#     puts "#{topic}: image received"
#   end
# end