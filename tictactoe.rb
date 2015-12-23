# win sequences constant
WIN_SEQUENCES = [[0, 1, 2], [3, 4, 5], [6, 7, 8],
                 [0, 3, 6], [1, 4, 7], [2, 5, 8],
                 [0, 4, 8], [2, 4, 6]]

# the game board
class Board
  attr_accessor :cells

  def initialize
    @cells = Array.new(9) # { nil }
  end

  def as_string
    stringed_board = @cells.map.with_index do |symbol, idx|
      symbol || idx + 1
    end

    stringed_board.each_slice(3).map do |row|
      "  #{row.join(' | ')}"
    end.join("\n ---+---+---\n")
  end

  def cell_open?(position)
    @cells[position - 1].nil?
  end

  def win_game?(symbol)
    WIN_SEQUENCES.any? do |seq|
      return true if seq.all? { |a| @cells[a] == symbol }
    end
  end

  def full?
    @cells.all?
  end

  def place_symbol(position, symbol)
    @cells[position - 1] = symbol
  end
end

# game logic
class Game
  def initialize
    @board = Board.new
    # default states
    @player1 = Human.new(@board, 'Player 1', 'X')
    @player2 = AI.new(@board, 'Evil AI', 'O')
    welcome_msg
    start_screen
  end

  private

  def start_screen(choice = gets.chomp)
    until (1..3).include?(choice)
      exit if choice.downcase == 'exit'
      select_game_mode(choice.to_i)
    end
  end

  def select_game_mode(choice)
    case choice
    when 1 then [@player2 = Human.new(@board, 'Player 2', 'O')]
    when 3 then [@player1 = AI.new(@board, 'Kind AI', 'X'),
                 @player2 = AI.new(@board, 'Evil AI', 'O')]
    else puts 'You silly goose, try again.'
    end
    @current_player = @player2
    display_board
    run_game
  end

  def welcome_msg
    print "\nWelcome to Tic Tac Toe.\n\n"
    puts 'Enter 1 to play against another player, 2 to play against an evil AI'\
         ', 3 to watch evil AI play against kind AI.'
    puts 'Type EXIT anytime to quit.'
  end

  def display_board
    puts "\e[H\e[2J" # ANSI clear
    print @board.as_string, "\n\n"
  end

  def run_game
    until game_over?
      swap_players
      check_and_place
      display_board
      display_result
    end
  end

  def game_over?
    @board.win_game?(@current_player.symbol) || @board.full?
  end

  def check_and_place
    position = @current_player.take_input
    @board.place_symbol(position.to_i, @current_player.symbol) unless position.nil?
  end

  def display_result
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

  def take_input(input = nil)
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
    check_win
    return @finished if @finished
    check_block
    return @finished if @finished
    check_defaults
    return @finished if @finished
    # failsafe check
    (1..9).reverse_each { |i| return i if board.cells[i - 1].nil? }
  end

  private

  # first check if possible to win before human player.
  def check_win
    @finished = false
    1.upto(9) do |i|
      origin = board.cells[i - 1]
      board.cells[i - 1] = symbol if origin.nil?
      # put it there if AI can win that way.
      return @finished = i if board.win_game?(symbol)
      board.cells[i - 1] = origin
    end
  end

  def other_symbol
    case symbol
    when 'X' then 'O'
    else 'X'
    end
  end

  # if impossible to win before player,
  # check if possible to block player from winning.
  def check_block
    @finished = false
    1.upto(9) do |i|
      origin = board.cells[i - 1]
      board.cells[i - 1] = other_symbol if origin.nil?
      # put it there if player can win that way.
      return @finished = i if board.win_game?(other_symbol)
      board.cells[i - 1] = origin
    end
  end

  # if impossible to win nor block, default placement to center.
  # if occupied, choose randomly between corners or sides.
  def check_defaults
    @finished = false
    if board.cells[4].nil?
      @finished = 5
    else
      rand < 0.51 ? possible_sides : possible_corners
    end
  end

  def possible_sides
    [2, 4, 6, 8].each do |i|
      return @finished = i if board.cells[i - 1].nil?
    end
  end

  def possible_corners
    [1, 3, 7, 9].each do |i|
      return @finished = i if board.cells[i - 1].nil?
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
