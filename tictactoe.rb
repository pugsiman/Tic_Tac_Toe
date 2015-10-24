# Main TicTacToe game class
class Game
  attr_writer :board # for tests

  def initialize
    @board = (1..9).to_a
    @running = true
    start_screen
  end

  def start_screen
    puts 'Welcome to Tic Tac Toe.'
    puts 'Enter 1 to play against another player, 2 to play against an evil AI.'
    puts 'Type EXIT anytime to quit.'

    choice = gets.chomp.to_i
    case choice
    when 1 then playergame_progress
    when 2 then aigame_progress
    else puts 'You silly, you.'
    end
  end

  def playergame_progress
    while @running
      turn(:X)
      result?
      break unless @running
      turn(:O)
      result?
    end
  end

  def aigame_progress
    rand > 0.3 ? player_first : ai_first
  end

  def turn(chosen_player)
    display_board
    puts "Choose a number (1-9) to place your mark on, Player #{chosen_player}."
    position = gets.chomp
    position = position.to_i unless position.to_i == 0

    if @board.include?(position)
      @board.map! do |num|
        if num == position
          chosen_player.to_s
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

  def display_board
    puts "\n -----------"
    @board.each_slice(3) do |row|
      print '  '
      puts row.join(' | ')
      puts ' -----------'
    end
    puts
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

  def win_game?
    sequences = [[0, 1, 2], [3, 4, 5], [6, 7, 8],
                 [0, 3, 6], [1, 4, 7], [2, 5, 8],
                 [0, 4, 8], [2, 4, 6]]

    sequences.each do |seq|
      if seq.all? { |a| @board[a] == 'X' } || seq.all? { |a| @board[a] == 'O' }
        return true
      end
    end
    false
  end

  def draw?
    @board.all? { |all| all.is_a? String } # returns true if no one has won.
  end

  def exit_game
    puts 'Wow, rude. Bye.'
    exit
  end

  # AI components
  def check_win
    # first check if possible to win before human player.
    @finished = false
    0.upto(8) do |i|
      origin = @board[i]
      @board[i] = 'O' unless @board[i] == 'X'
      if win_game?
        return @finished = true # early breakout if won game.
      else
        @board[i] = origin
      end
    end
  end

  def check_block
    # if impossible to win before player,
    # check if possible to block player from winning.
    @finished = false
    0.upto(8) do |i|
      origin = @board[i]
      @board[i] = 'X' unless @board[i] == 'O'
      if win_game?
        return [@finished = true, @board[i] = 'O']
        # if player can win that way, place it there.
      else
        @board[i] = origin
      end
    end
  end

  def possible_sides
    [1, 3, 5, 7].each do |idx|
      return @board[idx] = 'O' if @board[idx].is_a? Fixnum
    end
  end

  def possible_corners
    [0, 2, 6, 8].each do |idx|
      return @board[idx] = 'O' if @board[idx].is_a? Fixnum
    end
  end

  def check_defaults
    # if impossible to win nor block, default placement to center.
    # if occupied, choose randomly between corners or sides.
    if @board[4].is_a? Fixnum
      return @board[4] = 'O'
    else
      if rand > 0.499
        possible_sides
      else
        possible_corners
      end
    end
  end

  def loading_simulation
    str = "\rEvil AI is scheming"
    5.times do
      print str += '.'
      sleep(0.25)
    end
  end

  def ai_turn
    check_win
    return if @finished
    check_block
    return if @finished
    check_defaults
  end

  def player_first
    while @running
      turn(:X)
      result?
      break unless @running
      loading_simulation
      ai_turn
      result?
    end
  end

  def ai_first
    while @running
      loading_simulation
      ai_turn
      result?
      break unless @running
      turn(:X)
      result?
    end
  end
end

Game.new
