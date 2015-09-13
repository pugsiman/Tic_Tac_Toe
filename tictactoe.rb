#Adding a new method to the class String that allows to check if, for example, "2" is an integer "in disguise".
class String
	def is_integer?
		self.to_i.to_s == self
	end
end

module TicTacToe
	class Board
		
		def initialize
			@board = (1..9).to_a
			@running = true
			@exit = false
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
			elsif position.is_a?(String)
				if position.downcase == "exit"
					puts "Wow, rude. Bye."
					#using return for a special case of both declaring @running = false, and an early breakout.
					return @exit = true
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

			elsif position.is_a?(String)
				if position.downcase == "exit"
					puts "Wow, rude. Bye."
					#using return for a special case of both declaring @running = false, and an early breakout.
					return @exit = true
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
		
		def win_game?
			b = @board
			# horizontal win
			if  (
				(b[0..2].count("X") == 3 || b[0..2].count("O") == 3) ||
				(b[3..5].count("X") == 3 || b[3..5].count("O") == 3) ||
				(b[6..8].count("X") == 3 || b[6..8].count("O") == 3)
			) then return true
			# vertical win
			elsif (
				(b.values_at(0,3,6).count("X") == 3 || b.values_at(0,3,6).count("O") == 3) ||
				(b.values_at(1,4,7).count("X") == 3 || b.values_at(1,4,7).count("O") == 3) ||
				(b.values_at(2,5,8).count("X") == 3 || b.values_at(2,5,8).count("O") == 3)
			) then return true
			# diagonal win
			elsif (
				(b.values_at(0,4,8).count("X") == 3 || b.values_at(0,4,8).count("O") == 3) ||
				(b.values_at(2,4,6).count("X") == 3 || b.values_at(2,4,6).count("O") == 3)
			) then return true
			else
				return false
			end
		end
		
		def draw?
			@board.all? { |all| all.is_a? String}
		end
	
		def result?
			if win_game?
			  display_board
			  puts "Game Over!"
			  @running = false
			elsif draw?
			  display_board
			  puts "Tie!"
			  @running = false
			end
		end
  
		def game_progress
			until !@running
				x_turn
				break if @exit
				result?
				break if !@running
				o_turn
				break if @exit
				result?
			end
		end
		
	end
end

include TicTacToe
match = Board.new

match.game_progress