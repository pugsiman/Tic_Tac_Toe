module TicTacToe
	class Board
	attr_accessor :board
	
		def initialize
			@board = [1,2,3,4,5,6,7,8,9]
			@run = true
		end
		
		def display_board
			n = 0
			3.times do
				puts @board[n].to_s + " " + @board[n+1].to_s + " " + @board[n+2].to_s
				n += 3
			end
			
		end
	end
end
include TicTacToe
match = Board.new
match.display_board