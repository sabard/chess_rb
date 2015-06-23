require 'matrix'

class ChessRB::Position
  attr_accessor :fen

  def initialize(fen)
    @fen = fen
    @fen_components = fen.split(' ')
    @board = fen_to_board(fen)
    @valid = valid?
  end

  def self.valid_square?(s)
    i = s[0]; j = s[1]
    return i.is_a?(Integer) && j.is_a?(Integer) &&
      i >= 0 && i < 8 && j >= 0 && j < 8
  end

  # TODO
  def valid?
    return @valid if !@valid.nil?
    return true
  end

  # Returns 'w' or 'b' if it is white or black's move, respectively
  def turn
    return @fen_components[1]
  end

  # Returns the piece code on the given square
  def piece_on(square)
    if square.is_a?(String)
      file = ChessRB::Move.file(square)
      rank = ChessRB::Move.rank(square)
      return ChessRB::Piece.new(@board[8 - rank][file - 1])
    else
      return ChessRB::Piece.new(@board[square[0]][square[1]])
    end
  end

  def squares_with(piece)
    squares = []
    code = ChessRB::Piece.const_get(piece)

    @board.each_with_index do |r , i|
      r.each_with_index do |p, j|
        if p == code
          squares << [i, j]
        end
      end
    end

    return squares
  end

  # Returns if the current position is check, false otherwise
  def check?
    raise RuntimeError "Invalid Position" if !valid?

    t = turn().upcase
    not_t = t == 'W' ? 'B' : 'W'
    king_vector = Vector[*(squares_with(t + 'K')[0])]

    # check pawn squares
    pawn_vectors = t == 'W' ? [[-1, -1], [1, -1]] : [[-1, 1], [1, 1]]
    pawn_vectors.each do |s|
      s = (king_vector + Vector[*s]).to_a
      next if !self.class.valid_square?(s)
      return true if piece_on(s).desc == (not_t + 'P')
    end

    # check knight squares
    knight_vectors = [[1,2], [-1,2], [1,-2], [-1,-2], [2,1], [-2,1], [2,-1],
      [-2,-1]]
    knight_vectors.each do |s|
      s = (king_vector + Vector[*s]).to_a
      next if !self.class.valid_square?(s)
      return true if piece_on(s).desc == (not_t + 'N')
    end

    # check bishop/queen squares
    diagonal_vectors = [[1, 1], [-1, 1], [1, -1], [-1, -1]]
    diagonal_vectors.each do |v|
      dist = 1
      v = Vector[*v]
      while dist < 8
        current_vector = v * dist
        current_square = (king_vector + current_vector).to_a

        break if !self.class.valid_square?(current_square)

        p = piece_on(current_square).desc
        return true if p == (not_t + 'B') || p == (not_t + 'Q')
        break if p != 'E'

        dist += 1
      end
    end

    # check rook/queen squares
    straight_vectors = [[1, 0], [0, 1], [-1, 0], [0, -1]]
    straight_vectors.each do |v|
      dist = 1
      v = Vector[*v]
      while dist < 8
        current_vector = v * dist
        current_square = (king_vector + current_vector).to_a

        break if !self.class.valid_square?(current_square)

        p = piece_on(current_square).desc
        return true if p == (not_t + 'B') || p == (not_t + 'Q')
        break if p != 'E'

        dist += 1
      end
    end

    return false
  end

  # Returns if the current position is checkmate, false otherwise
  def mate?
    return false if !check?

    t = turn().upcase
    king_vector = Vector[*(squares_with(t + 'K')[0])]

    around_vectors = [[1, 0], [0, 1], [-1, 0], [0, -1], [1, 1], [-1, 1],
      [1, -1], [-1, -1]]
    around_vectors.each do |v|
      v = Vector[*v]
      current_square = (king_vector + v).to_a
      if !self.class.valid_square?(current_square) ||
        piece_on(current_square).color == t

        next
      else
        undo_code = piece_on(current_square).code
        move(king_vector.to_a, current_square)
        if !check?
          undo(king_vector.to_a, current_square, undo_code)
          return false
        end
        undo(king_vector.to_a, current_square, undo_code)
      end
    end

    return true
  end

  def make_move(move)
    move([8 - move.from_rank, move.from_file - 1],
      [8 - move.to_rank, move.to_file - 1])

    update_fen(true)
  end

  def undo_move(move, piece)
    undo([8 - move.from_rank, move.from_file - 1],
      [8 - move.to_rank, move.to_file - 1], piece.code)

    update_fen(false)
  end

  def to_s(dark_background = true)
    str = ""
    @board.each_with_index do |r, i|
      str += (8 - i).to_s + "║"
      r.each do |s|
        str += " "
        if s == 0
          str += "…"
        else
          str += ChessRB::Piece.new(s).to_s(dark_background)
        end
      end
      str += "\n"
    end
    str += " ╚════════════════\n   A B C D E F G H"
    return str
  end

  private

  def fen_to_board(f)
    board = Array.new(8) {Array.new(8,0)}
    rows = f.split(' ')[0].split('/')
    rows.each_with_index do |r, i|
      j = 0
      r.each_char do |c|
        if c.to_i != 0
          j += c.to_i
        else
          color = /[[:upper:]]/.match(c) ? 'W' : 'B'
          if c.upcase == 'B'
            c = i + j % 2 == 0 ? 'DB' : 'LB'
          end
          board[i][j] = ChessRB::Piece.const_get(color + c.upcase)
          j += 1
        end
      end
    end
    return board
  end

  def board_to_fen
    fen = ""

    @board.each_with_index do |r, i|
      fen += '/' if i != 0
      count = 0
      r.each_with_index do |c|
        p = ChessRB::Piece.new(c)
        if p.empty?
          count += 1
        else
          fen += count.to_s if count != 0
          count = 0
          if p.color == 'W'
            fen += p.type.upcase
          else
            fen += p.type.downcase
          end
        end
      end
      fen += count.to_s if count != 0
    end

    puts fen.to_s
    return fen
  end

  def move(from, to)
    @board[to[0]][to[1]] = @board[from[0]][from[1]]
    @board[from[0]][from[1]] = 0
  end

  def undo(from, to, code)
    @board[from[0]][from[1]] = @board[to[0]][to[1]]
    @board[to[0]][to[1]] = code
  end

  def update_fen(forward)
    @fen_components[1] = @fen_components[1] == 'w' ? 'b' : 'w'
    @fen_components[0] = board_to_fen()
    if forward
      # do things for make_move
    else
      # do things for undo_move
    end
    @fen = @fen_components.join(' ')
  end
end
