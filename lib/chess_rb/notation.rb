class ChessRB::Notation
  def self.square_to_algebraic(move)
    board = move.board
    piece = ChessRB::Piece.new(board.piece_on(move.from))
    san = ""

    raise ArgumentError.new "Invalid move and/or position" if !move.valid? ||
      !board.valid?


    if move.queen_castle?
      san = "O-O-O"
    elsif move.king_castle?
      san = "O-O"
    else
      if piece.type == 'p'
        if move.capture?
          san = file_to_char(move.from_file)
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

=begin
    board.make_move(move)
    if (board.check?)
      san += board.mate? ? "#" : "+"
    end
    board.undo_move(move)
=end

    return san
  end

  # TODO
  def self.algebraic_to_square(move)
    return move.square
  end
end
