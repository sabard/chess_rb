class ChessRB::Position
  attr_accessor :fen

  def initialize(fen)
    @fen = fen
    @fen_components = fen.split(' ')
    @board = fen_to_board(fen)
  end

  # TODO
  def valid?
    return true
  end

  # Returns the piece code on the given square
  def piece_on(square)
    file = ChessRB::Move.file(square)
    rank = ChessRB::Move.rank(square)
    return @board[8 - rank][file - 1]
  end

  # TODO
  def check?

  end

  # TODO
  def mate?

  end

  def to_s(dark_background = true)
    str = ""
    board.each_with_index do |r, i|
      str += (8 - i).to_s + "║"
      r.each do |s|
        str += " "
        if s == 0
          str += "…"
        else
          str += ChessRB::Piece.code_to_s(s, dark_background)
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
end
