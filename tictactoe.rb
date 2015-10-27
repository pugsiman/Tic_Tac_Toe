# players in the game
class Player
  attr_reader :name, :symbol

  def initialize(name, symbol)
    @name = name
    @symbol = symbol
  end
end

# the game board
class Board
  attr_accessor :board

  def initialize
    @board = (1..9).to_a
  end

  def display_board
    # puts "\e[H\e[2J" # ANSI clear
    @board.each_slice(3).with_index do |row, idx|
      print "  #{row.join(' | ')}\n"
      puts ' ---+---+---' unless idx == 2
    end
    puts
  end

  def welcome_msg
    puts 'Welcome to Tic Tac Toe.'
    puts 'Enter 1 to play against another player, 2 to play against an evil AI.'
    puts 'Type EXIT anytime to quit.'
  end

  def cell_open?(position)
    @board[position - 1].is_a?(Fixnum) ? true : false
  end

  def win_game?(symbol)
    sequences = [[0, 1, 2], [3, 4, 5], [6, 7, 8],
                 [0, 3, 6], [1, 4, 7], [2, 5, 8],
                 [0, 4, 8], [2, 4, 6]]

    sequences.each do |seq|
      return true if seq.all? { |a| @board[a] == symbol }
    end
    false
  end

  def full?
    @board.each do |cell|
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
  attr_accessor :board, :player1, :player2, :ai, :current_player

  def initialize
    @board = Board.new
    @player1 = Player.new('Player 1', 'X')
    @player2 = Player.new('Player 2', 'O')
    @ai = AI.new('Evil AI', 'O')
    @current_player = @player1
    # @ai.board.display_board
    start_screen
  end

  def start_screen
    @board.welcome_msg
    choice = nil
    until (1..2).include? choice
      choice = gets.chomp.to_i
      case choice
      when 1 then players_turn
      when 2 then pva_turn
      else        puts 'You silly goose, try again.'
      end
    end
  end

  def players_turn
    @board.display_board
    until @board.win_game?(@current_player.symbol) || @board.full?
      position = player_input
      @board.place_mark(position.to_i, @current_player.symbol)
      @board.display_board
      result?
      swap_players
    end
  end

  def player_input
    input = nil
    until (1..9).include?(input) && @board.cell_open?(input)
      puts "Choose a number (1-9) to place your mark #{@current_player.name}."
      input = validate_input(gets.chomp)
    end
    input
  end

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

  def swap_players
    if @current_player == @player1
      @current_player = @player2
    else
      @current_player = @player1
    end
  end

  def swap_pva
    if @current_player == @player1
      @current_player = @ai
    else
      @current_player = @player1
    end
  end

  def pva_turn
    @board.display_board
    until @board.win_game?(@current_player.symbol) || @board.full?
      position = player_input
      @board.place_mark(position.to_i, @current_player.symbol)
      @board.display_board
      result?
      swap_pva
      break if @board.win_game?(@current_player.symbol) || @board.full?
      position = @ai.ai_turn(@board)
      @board.place_mark(position.to_i, @current_player.symbol)
      @board.display_board
      result?
      swap_pva
    end
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
end

# AI player components
class AI
  attr_accessor :board, :name, :symbol

  def initialize(name, symbol)
    @name = name
    @symbol = symbol
  end

  def ai_turn(board)
    @finished = false
    check_win(board)
    check_block(board) unless @finished
    check_defaults(board) unless @finished
  end

  def check_win(board)
    # first check if possible to win before human player.
    1.upto(9) do |i|
      origin = board.board[i - 1]
      board.board[i - 1] = 'O' unless board.board[i - 1] == 'X'
      if board.win_game?('O')
        @finished = true
        return i
      else
        board.board[i - 1] = origin
      end
    end
  end

  def check_block(board)
    # if impossible to win before player,
    # check if possible to block player from winning.
    @finished = false
    1.upto(9) do |i|
      origin = board.board[i - 1]
      board.board[i - 1] = 'X' unless board.board[i - 1] == 'O'
      if board.win_game?('X')
        @finished = true
        return i # put it there if player can win that way.
      else
        board.board[i - 1] = origin
      end
    end
  end

  def check_defaults(board)
    @finished = false
    # if impossible to win nor block, default placement to center.
    # if occupied, choose randomly between corners or sides.
    if board.board[4].is_a? Fixnum
      @finished = true
      return 5
    else
      rand > 0.499 ? possible_sides(board) : possible_corners(board)
    end
  end

  def possible_sides(board)
    [2, 4, 6, 8].each do |idx|
      if board.board[idx - 1].is_a? Fixnum
        @finished = true
        return idx
      end
    end
  end

  def possible_corners(board)
    [1, 3, 7, 9].each do |idx|
      if board.board[idx - 1].is_a? Fixnum
        @finished = true
        return idx
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
end

Game.new
