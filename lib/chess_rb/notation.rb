class ChessRB::Notation
  def self.square_to_algebraic(move)
    board = move.board
    piece = board.piece_on(move.from)
    san = ""

    raise ArgumentError.new "Invalid move and/or position" if !move.valid? ||
      !board.valid?


    if move.queen_castle?
      return "O-O-O"
    elsif move.king_castle?
      return "O-O"
    else
      if piece.type == 'P'
        if move.capture?
          san = move.from[0]
        end
      else
        san += piece.type.upcase

        # test ambiguities
        # file
        # rank
        # both
      end
    end

    if move.capture?
      san += "x"
    end

    san += move.to

    san += "=#{move.promotion}" if move.promotion

    if !board.squares_with(['WK', 'BK']).empty?
      undo_info = board.piece_on(move.to)
      board.make_move(move)
      if (board.check?)
        san += board.mate? ? "#" : "+"
      end
      board.undo_move(move, undo_info)
    end

    return san
  end

  # TODO
  def self.algebraic_to_square(move)
    return move.square
  end
end
