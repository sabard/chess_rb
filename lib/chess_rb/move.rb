class ChessRB::Move
  FILE_CONV = [nil, 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h']

  attr_reader :to, :from, :promotion, :square, :san, :board

  def initialize(move, pos, promotion = nil)
    if move.split('-').length == 2
      @square = move
    else
      @san = move
    end

    if pos.is_a?(String)
      @board = ChessRB::Position.new pos
    else
      @board = pos
    end

    @promotion = promotion

    @square = ChessRB::Notation.algebraic_to_square(self) if @square.nil?

    squares = @square.split('-')
    @from = squares[0]
    @to = squares[1]

    @san = ChessRB::Notation.square_to_algebraic(self) if @san.nil?

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
    return valid? && @board.piece_on(@from).type == 'K' &&
      from_file - to_file == 2
  end

  # Returns true if move represents a king-side castle, false otherwise.
  def king_castle?
    return valid? && @board.piece_on(@from).type == 'K' &&
      to_file - from_file == 2
  end

  # Returns true if move results in a capture, false otherwise.
  def capture?
    return valid? && @board.piece_on(@to).desc != 'E'
  end

  # Returns the rank of a given square
  def self.rank(square)
    return square[1].to_i
  end

  # Returns rank of this move's @to square
  def to_rank
    return self.class.rank(@to)
  end

  # Returns rank of this move's @from square
  def from_rank
    return self.class.rank(@from)
  end

  # Returns the file of a given square as a number (e.g., a = 1, b = 2, ...)
  def self.file(square)
    return FILE_CONV.index(square[0])
  end

  # Returns file of this move's @to square
  def to_file
    return self.class.file(@to)
  end

  # Returns file of this move's @from square
  def from_file
    return self.class.file(@from)
  end
end
