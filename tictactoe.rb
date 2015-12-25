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
    stringed_board = @cells.map.with_index(1) do |symbol, idx|
      symbol || idx
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
      seq.all? { |a| @cells[a] == symbol }
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
    @current_player = @player2
    welcome_msg
    start_screen
  end

  private

  def start_screen(choice = gets)
    choice.strip!.downcase! if choice
    until %w(1 2 3 exit).include?(choice)
      puts 'You silly goose, try again.'
      choice = gets.chomp.downcase
    end
    select_game_mode(choice)
    display_board
    run_game
  end

  def select_game_mode(choice)
    case choice
    when '1'    then @player2 = Human.new(@board, 'Player 2', 'O')
    when '3'    then @player1 = AI.new(@board, 'Kind AI', 'X')
    when 'exit' then exit
    end
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
      if game_over?
        puts display_result
        exit
      end
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
      "Game Over, #{@current_player.name} has won."
    elsif @board.full?
      'Draw.'
    end
  end

  def swap_players
    case @current_player
    when @player1 then @current_player = @player2
    else               @current_player = @player1
    end
  end
end

# players in the game
class Player
  attr_reader :name, :symbol

  def initialize(board, name, symbol)
    @board = board
    @name = name
    @symbol = symbol
  end
end

# human players in the game
class Human < Player
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
class AI < Player
  attr_reader :board

  def take_input
    loading_simulation
    win_or_block(symbol) || win_or_block(other_symbol) || check_defaults
  end

  private

  # first check if possible to win before human player.
  # if not, check if possible to block opponent from winning.
  def win_or_block(sym)
    finished = false
    0.upto(8) do |i|
      origin = board.cells[i]
      board.cells[i] = sym if origin.nil?
      finished = i + 1 if board.win_game?(sym)
      board.cells[i] = origin
    end
    finished
  end

  # default to center, if occupied, choose randomly between sides and corners.
  # if occupied after random throw, execute reverse failsafe check.
  def check_defaults
    if board.cells[4]
      rand < 0.51 ? possible_position(&:even?) : possible_position(&:odd?)
    else
      5
    end
  end

  def possible_position(&block)
    result = (0..8).select(&block).each do |i|
      return i + 1 if board.cells[i].nil?
    end
    result.is_a?(Integer) ? result : board.cells.rindex(nil) + 1
  end

  def other_symbol
    symbol == 'X' ? 'O' : 'X'
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
