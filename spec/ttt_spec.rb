require '../tictactoe.rb'

# The game is initially not planned so well object oriented design-wise,
# So the tests are limited to the basic methods.
# Since then, the game undergone deep changes and is much better.

describe Game do
  let(:game) { Game.new }

  describe '#start_screen' do
    it 'displays introduction to the game' do
      expect(game.start_screen)
    end
  end

  describe '#display_board' do
    it 'displays the board' do
      expect(game.display_board)
    end
  end

  describe '#win_game?' do
    it 'returns true if game is won, and false if not' do
      game.board = ['X', 'X', 'X', 4, 5, 6, 7, 8, 9]
      expect(game.win_game?).to eq true
      game.board = ['X', 2, 3, 4, 'X', 6, 7, 8, 'X']
      expect(game.win_game?).to eq true
      game.board = ['O', 2, 3, 4, 'O', 6, 7, 8, 'O']
      expect(game.win_game?).to eq true
      game.board = ['X', 'O', 'X', 4, 5, 6, 7, 8, 9]
      expect(game.win_game?).to eq false
    end
  end

  describe '#draw?' do
    it 'returns true if game is finished in draw, and false if not' do
      game.board = %w(X X O O X O O X O)
      expect(game.draw?).to eq true
      game.board = %w(X X O O X O O X O)
      expect(game.draw?).to eq true
      game.board = ['O', 2, 3, 4, 'X', 6, 7, 8, 'O']
      expect(game.draw?).to eq false
    end
  end

  describe '#check_win' do
    it 'places mark on winning position if it will lead to win' do
      game.board = ['X', 'O', 3, 4, 'O', 'X', 7, 8, 9]
      expect(game.check_win)
      expect(game.win_game?).to eq true
    end
  end

  describe '#check_block' do
    it 'places mark on blocking position if it will block player\'s win' do
      game.board = ['X', 'X', 3, 4, 'O', 6, 7, 8, 9]
      expect(game.check_block)
      expect(game.win_game?).to eq false
    end
  end
end
