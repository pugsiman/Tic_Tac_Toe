
# the game board
class Board
  attr_accessor :board

  def initialize
    @board = (1..9).to_a
  end

  def display_board
    puts "\e[H\e[2J" # ANSI clear
    @board.each_slice(3).with_index do |row, idx|
      print "  #{row.join(' | ')}\n"
      puts ' ---+---+---' unless idx == 2
    end
    puts
  end

  def welcome_msg
    print "\nWelcome to Tic Tac Toe.\n\n"
    puts 'Enter 1 to play against another player, 2 to play against an evil AI'\
         ', 3 to watch evil AI play against kind AI.'
    puts 'Type EXIT anytime to quit.'
  end

  def cell_open?(position)
    @board[position - 1].is_a?(Fixnum)
  end

  def win_game?(symbol)
    sequences = [[0, 1, 2], [3, 4, 5], [6, 7, 8],
                 [0, 3, 6], [1, 4, 7], [2, 5, 8],
                 [0, 4, 8], [2, 4, 6]]

    sequences.any? do |seq|
      return true if seq.all? { |a| @board[a] == symbol }
    end
    false
  end

  def full?
    @board.any? do |cell|
      return false if cell.is_a? Fixnum
    end
    true
  end

  def place_mark(position, symbol)
    @board[position - 1] = symbol
  end
end

# game logic
class Game
  def initialize
    @board = Board.new
    start_screen
  end

  def start_screen(choice = nil)
    @board.welcome_msg
    until (1..3).include?(choice)
      choice = gets.chomp
      exit if choice.downcase == 'exit'
      game_modes(choice.to_i)
    end
  end

  def game_modes(choice)
    @board.display_board
    case choice
    when 1
      @player1 = Human.new(@board, 'Player 1', 'X')
      @player2 = Human.new(@board, 'Player 2', 'O')
    when 2
      @player1 = Human.new(@board, 'Player 1', 'X')
      @player2 = AI.new(@board, 'Evil AI', 'O')
    when 3
      @player1 = AI.new(@board, 'Kind AI', 'X')
      @player2 = AI.new(@board, 'Evil AI', 'O')
    else puts 'You silly goose, try again.'
    end
    @current_player = @player2
    run_game
  end

  def run_game
    until game_over
      swap_players
      player_place_n_check
    end
  end

  def game_over
    @board.win_game?(@current_player.symbol) || @board.full?
  end

  def player_place_n_check
    position = @current_player.take_input
    @board.place_mark(position.to_i, @current_player.symbol) unless position.nil?
    @board.display_board
    result?
  end

  def result?
    if @board.win_game?(@current_player.symbol)
      puts "Game Over, #{@current_player.name} has won."
      exit
    elsif @board.full?
      puts 'Draw.'
      exit
    end
  end

  def swap_players
    case @current_player
    when @player1 then @current_player = @player2
    else               @current_player = @player1
    end
  end
end

# human players in the game
class Human
  attr_reader :name, :symbol

  def initialize(board, name, symbol)
    @board = board
    @name = name
    @symbol = symbol
  end

  def take_input
    input = nil
    until (1..9).include?(input) && @board.cell_open?(input)
      puts "Choose a number (1-9) to place your mark #{name}."
      input = validate_input(gets.chomp)
    end
    input
  end

  private

  def validate_input(input)
    if input.to_i == 0
      exit if input.downcase == 'exit'
      puts 'You can\'t use a string, silly.'
    else
      position = validate_position(input.to_i)
    end
    position
  end

  def validate_position(position)
    if !(1..9).include? position
      puts 'This position does not exist, chief.'
      puts 'Try again or type EXIT to, well, exit.'
    elsif !@board.cell_open? position
      puts 'Nice try but this cell is already taken.'
      puts 'Try again or type EXIT to, well, exit.'
    end
    position
  end
end

# AI players in the game
class AI
  attr_reader :name, :symbol, :board

  def initialize(board, name, symbol)
    @board = board
    @name = name
    @symbol = symbol
  end

  def take_input
    loading_simulation
    check_win(board)
    return @finished if @finished
    check_block(board)
    return @finished if @finished
    check_defaults(board)
    return @finished if @finished
  end

  private

  # first check if possible to win before human player.
  def check_win(board)
    @finished = false
    1.upto(9) do |i|
      origin = board.board[i - 1]
      board.board[i - 1] = 'O' if origin.is_a? Fixnum
      # put it there if AI can win that way.
      return @finished = i if board.win_game?('O')
      board.board[i - 1] = origin
    end
  end

  # if impossible to win before player,
  # check if possible to block player from winning.
  def check_block(board)
    @finished = false
    1.upto(9) do |i|
      origin = board.board[i - 1]
      board.board[i - 1] = 'X' if origin.is_a? Fixnum
      # put it there if player can win that way.
      return @finished = i if board.win_game?('X')
      board.board[i - 1] = origin
    end
  end

  # if impossible to win nor block, default placement to center.
  # if occupied, choose randomly between corners or sides.
  def check_defaults(board)
    @finished = false
    if board.board[4].is_a? Fixnum
      @finished = 5
    else
      rand < 0.51 ? possible_sides(board) : possible_corners(board)
    end
  end

  def possible_sides(board)
    [2, 4, 6, 8].each do |i|
      return @finished = i if board.board[i - 1].is_a? Fixnum
    end
  end

  def possible_corners(board)
    [1, 3, 7, 9].each do |i|
      return @finished = i if board.board[i - 1].is_a? Fixnum
    end
  end

  def loading_simulation
    str = "\r#{name} is scheming"
    10.times do
      print str += '.'
      sleep(0.1)
    end
  end
end

Game.new
