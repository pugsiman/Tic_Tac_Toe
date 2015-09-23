# Adding a new method to the class String that allows to check if,
# for example, "2" is an integer "in disguise".
class String
  def is_integer?
    self.to_i.to_s == self
  end
end

module TicTacToe
  class Game
    def initialize
      @board = (1..9).to_a
      @running = true
      @exit = false
    end

    def display_board
      puts "\n -----------"
      @board.each_slice(3) do |row| 
        print '  '
        puts row.join(' | ')
        puts ' -----------'
      end
      puts ''
    end

    def x_turn
      display_board
      puts 'Choose a number (1-9) to place your mark on, Player 1.'
      position = gets.chomp

      # using personal created method to determine input
      position = position.to_i if position.is_integer?

      if @board.include?(position)
        @board.map! do |num|
          if num == position
            'X'
          else
            num
          end
        end
      elsif position.is_a?(String)
        if position.downcase == 'exit'
          puts 'Wow, rude. Bye.'
          return @exit = true # return for a special case of both declaring,
          # and an early breakout.
        end
        puts 'Position can only be a number, silly.'
        puts 'Try again or type EXIT to, well, exit.'
        x_turn
      else
        puts 'This position does not exist or already occupied, chief.'
        puts 'Try again or type EXIT to, well, exit.'
        x_turn
      end
    end

    def o_turn
      display_board
      puts 'Choose a number (1-9) to place your mark on, Player 2.'
      position = gets.chomp

      # using personal created method to detemine input.
      if position.is_integer?
        position = position.to_i
      end

      if @board.include?(position)
        @board.map! do |num|
          if num == position
            'O'
          else
            num
          end
        end

      elsif position.is_a?(String)
        if position.downcase == 'exit'
          puts 'Wow, rude. Bye.'
          return @exit = true # return for a special case of both declaring,
          # and an early breakout.
        end
        puts 'Position can only be a number, silly.'
        puts 'Try again or type EXIT to, well, exit.'
        o_turn
      else
        puts 'This position does not exist or already occupied, chief.'
        puts 'Try again or type EXIT to, well, exit.'
        o_turn
      end
    end

    def win_game?
      sequences = [[0,1,2],[3,4,5],[6,7,8],
                   [0,3,6],[1,4,7],[2,5,8],
                   [0,4,8],[2,4,6]]
      b = @board

      sequences.each do |sequence|
        if sequence.all? { |a| b[a] == "X"}
          return true
        elsif sequence.all? { |a| b[a] == "O"}
          return true
        end
      end
      false
    end

    def draw?
      @board.all? { |all| all.is_a? String } # returns true if no one won by the end of the match.
    end

    def result?
      if win_game?
        display_board
        puts 'Game Over'
        @running = false
      elsif draw?
        display_board
        puts 'Draw'
        @running = false
      end
    end

    def playergame_progress
      while @running
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
  # AI components
  def try_sides
    [1,3,5,7].each do |idx|
      if @board[idx].is_a? Fixnum
        return @board[idx] = 'O'
      end
    end
  end

  def try_corners
    [0,2,6,8].each do |idx|
      if @board[idx].is_a? Fixnum
        return @board[idx] = 'O'
      end
    end
  end

  def ai_turn
    # first check if possible to win before human player.
    for i in (0...9)
      origin = @board[i]
      @board[i] = 'O' if @board[i] != 'X'
      win_game? ? return : @board[i] = origin # using return for early breakout if win_game? is true.
    end

    # if not possible to win before player, check if possible to block player from winning.
    for i in (0...9)
      origin = @board[i]
      @board[i] = 'X' if @board[i] != 'O'
      if win_game?
        return @board[i] = 'O' # if player can win that way, place it there before him.
      else
        @board[i] = origin
      end
    end

    # if impossible to win nor block, default placement to center.
    # if default is occupied, choose between corners or sides randomly.
    if !@board[4].is_a? String
      return @board[4] = 'O'
    else
      rand > 0.499 ? try_sides || try_corners : try_corners || try_sides
    end
  end
  
  def thinking_simulation
    [0.5, 0.4, 0.3, 0.2].each_with_index do |time, idx|
      puts
      print 'Evil A.I. is scheming.'
      idx.times {print '.'}
      sleep(time)
    end
    puts
  end
  
  def aigame_progress
    if rand > 0.3
      while @running
        x_turn
        break if @exit
        result?
        break if !@running
        thinking_simulation
        ai_turn
        result?
      end
    else
      while @running
        thinking_simulation
        ai_turn
        result?
        break if !@running
        x_turn
        break if @exit
        result?
      end
    end
  end
end

def play
  include TicTacToe
  match = Game.new
  
  puts 'Welcome to Tic Tac Toe, enter 1 to play against another player, or 2 to play against an evil A.I.'
  puts 'Type EXIT anytime to quit.'
  
  choice = gets.chomp.to_i
  case choice
  when 1 then match.playergame_progress
  when 2 then match.aigame_progress
  else        puts 'You silly, you.'
  end
end

play