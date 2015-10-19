# Checks if, for example, "2" is an integer "in disguise".
class String
  def is_integer?
    to_i.to_s == self
  end
end

# Main TicTacToe game class
class Game
  def initialize
    @board = (1..9).to_a
    @running = true
  end

  def display_board
    puts "\n -----------"
    @board.each_slice(3) do |row|
      print '  '
      puts row.join(' | ')
      puts ' -----------'
    end
    puts
  end

  def turn(chosen_player)
    display_board
    puts "Choose a number (1-9) to place your mark on, Player #{chosen_player}."
    position = gets.chomp

    # using personal created method to determine input
    position = position.to_i if position.is_integer?

    if @board.include?(position)
      @board.map! do |num|
        if num == position
          determine_player(chosen_player)
        else
          num
        end
      end
    elsif position.is_a?(String)
      exit_game if position.downcase == 'exit'
      puts 'Position can only be a number, silly.'
      puts 'Try again or type EXIT to, well, exit.'
      turn(chosen_player)
    else
      puts 'This position does not exist or already occupied, chief.'
      puts 'Try again or type EXIT to, well, exit.'
      turn(chosen_player)
    end
  end

  def exit_game
    puts 'Wow, rude. Bye.'
    exit
  end

  def determine_player(player)
    player.to_s
  end

  def win_game?
    sequences = [[0, 1, 2], [3, 4, 5], [6, 7, 8],
                 [0, 3, 6], [1, 4, 7], [2, 5, 8],
                 [0, 4, 8], [2, 4, 6]]

    sequences.each do |sequence|
      if sequence.all? { |a| @board[a] == 'X' }
        return true
      elsif sequence.all? { |a| @board[a] == 'O' }
        return true
      end
    end
    false
  end

  def draw?
    @board.all? { |all| all.is_a? String } # returns true if no one has won.
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
      turn(:X)
      result?
      break if !@running
      turn(:O)
      result?
    end
  end

  # AI components
  def try_sides
    [1, 3, 5, 7].each do |idx|
      return @board[idx] = 'O' if @board[idx].is_a? Fixnum
    end
  end

  def try_corners
    [0, 2, 6, 8].each do |idx|
      return @board[idx] = 'O' if @board[idx].is_a? Fixnum
    end
  end

  def ai_turn
    # first check if possible to win before human player.
    0.upto(8) do |i|
      origin = @board[i]
      @board[i] = 'O' unless @board[i] == 'X'
      win_game? ? return : @board[i] = origin # early breakout if won game.
    end

    # if impossible to win before player, check if possible to block player from winning.
    0.upto(8) do |i|
      origin = @board[i]
      @board[i] = 'X' unless @board[i] == 'O'
      if win_game?
        return @board[i] = 'O' # if player can win that way, place it there.
      else
        @board[i] = origin
      end
    end

    # if impossible to win nor block, default placement to center.
    # if occupied, choose randomly between corners or sides.
    if @board[4].is_a? Fixnum
      return @board[4] = 'O'
    else
      rand > 0.499 ? try_sides || try_corners : try_corners || try_sides
    end
  end

  def thinking_simulation
    str = "\rEvil AI is scheming"
    5.times do
      print str += '.'
      sleep(0.3)
    end
  end

  def aigame_progress
    if rand > 0.3
      while @running
        turn(:X)
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
        turn(:X)
        result?
      end
    end
  end
end

def play
  match = Game.new

  puts 'Welcome to Tic Tac Toe.'
  puts 'Enter 1 to play against another player, 2 to play against an evil AI.'
  puts 'Type EXIT anytime to quit.'

  choice = gets.chomp.to_i
  case choice
  when 1 then match.playergame_progress
  when 2 then match.aigame_progress
  else        puts 'You silly, you.'
  end
end

play
