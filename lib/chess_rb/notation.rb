class ChessRB::Notation
  def self.square_to_algebraic(move)
    board = move.board
    piece = board.piece_on(move.from)
    san = ""

    raise ArgumentError.new "Invalid move and/or position" if !move.valid? ||
      !board.valid?


    if move.queen_castle?
      san = "O-O-O"
    elsif move.king_castle?
      san = "O-O"
    else
      if piece.type == 'P'
        if move.capture?
          san = file_to_char(square_file(move.from))
        end
      else
        # test ambiguities
        # file
        # rank
        # both
      end
    end

    if move.capture?
      str += "x"
    end

    str += move.to

    str += "=#{move.promotion}" if move.promotion

    board.make_move(move)
    if (board.check?)
      str += board.mate? ? "#" : "+"
    end
    board.undo_move(move)

    return str
  end

  # TODO
  def self.algebraic_to_square(move)

  end
end
