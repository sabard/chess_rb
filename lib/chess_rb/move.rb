class ChessRB::Move
  FILE_TO_NUM = [nil, 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h']

  attr_reader :to, :from, :promotion, :square, :san

  def intialize(move, pos, promotion = nil)
    if (squares = move.split('-')).length == 2
      @square = move
      @san = ChessRB::Notation.square_to_algebraic(move)
    else
      @san = move
      @square = ChessRB::Notation.algebraic_to_square(move)
    end

    @from = squares[0]
    @to = squares[1]

    if pos.is_a? String
      @board = Board.new pos
    else
      @board = pos
    end

    @promotion = promotion
    @valid = valid?
  end

  # TODO
  # Returns true if move is a legal move in the given position, false otherwise.
  def valid?
    return @valid if !@valid.nil?
    return true
  end

  # Returns true if move represents a queen-side castle, false otherwise.
  def queen_castle?

    return valid? && ChessRB::Piece.new(@board.piece_on(@to)).type == 'k' &&
      (from_file - to_file).abs == 3
  end

  # Returns true if move represents a king-side castle, false otherwise.
  def king_castle?
    return valid? && ChessRB::Piece.new(@board.piece_on(@to)).type == 'k' &&
     (from_file - to_file).abs == 2
  end

  # Returns true if move results in a capture, false otherwise.
  def capture?
    return valid? && @board.piece_on(@to) != 0
  end

  # Returns the rank of a given square
  def self.rank(square)
    return square[1].to_i
  end

  # Returns rank of this move's @to square
  def to_rank
    return self.rank(@to)
  end

  # Returns rank of this move's @from square
  def from_rank
    return self.rank(@from)
  end

  # Returns the file of a given square as a number (e.g., a = 1, b = 2, ...)
  def self.file(square)
    return FILE_TO_NUM.index(square[0])
  end

  # Returns file of this move's @to square
  def to_file
    return self.file(@to)
  end

  # Returns file of this move's @from square
  def from_file
    return self.file(@from)
  end
end
