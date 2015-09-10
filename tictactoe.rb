module TicTacToe
	class Board
	attr_accessor :board
	
		def initialize
			@board = (1..9).to_a
			@run
		end
		
		def display_board
			n = 0
			b = @board
			3.times do
				puts b[n].to_s + " " + b[n+1].to_s + " " + b[n+2].to_s
				n += 3
			end
			
		end
	end
end
include TicTacToe
match = Board.new
match.display_board