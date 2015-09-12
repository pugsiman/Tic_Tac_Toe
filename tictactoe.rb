#Adding a new method to the class String that allows to check if, for example, "2" is an integer "in disguise".
class String
	def is_integer?
		self.to_i.to_s == self
	end
end

module TicTacToe
	class Board
	#attr_accessor :board
	
		def initialize
			@board = (1..9).to_a
			@running = true
		end
		
		def display_board
			n = 0
			b = @board
			3.times do
				puts b[n].to_s + " " + b[n+1].to_s + " " + b[n+2].to_s
				n += 3
			end
		end
		
		def x_turn
			display_board
			puts "Choose a number (1-9) to place your mark on, Player 1."
			position = gets.chomp
			
			#using personal created method
			if position.is_integer?
				position = position.to_i
			end
			
			if @board.include?(position)
				@board.map! do |num|
					if num == position
						num = "X"
					else
						num
					end
				end
			elsif position.is_a?(String) == true
				if position.downcase == "exit"
					puts "Wow, rude. Bye."
					@running = false
					return
				end
				puts "Position can only be a number, silly."
				puts "Try again or type EXIT to, well, exit."
				x_turn
			else
				puts "This position does not exist or already occupied, chief."
				puts "Try again or type EXIT to, well, exit."
				x_turn
			end
		end
		
		def o_turn
			display_board
			puts "Choose a number (1-9) to place your mark on, Player 2."
			position = gets.chomp
			
			#using personal created method
			if position.is_integer?
				position = position.to_i
			end

			if @board.include?(position)
				@board.map! do |num|
					if num == position
						num = "O"
					else
						num
					end
				end

			elsif position.is_a?(String) == true
				if position.downcase == "exit"
					puts "Wow, rude. Bye."
					@running = false
					return
				end
				puts "Position can only be a number, silly."
				puts "Try again or type EXIT to, well, exit."
				o_turn
			else
				puts "This position does not exist or already occupied, chief."
				puts "Try again or type EXIT to, well, exit."
				o_turn
			end
		end
		
		def play
			#until win_game == true
				if @running;
				else
					return
				end
			
				x_turn
				if @running;
				else
					return
				end
				
				o_turn
				if @running;
				else
					return
				end
				
				display_board
			#end
		end
		
		def win_game
			false
		end
	end
end

include TicTacToe
match = Board.new
match.play