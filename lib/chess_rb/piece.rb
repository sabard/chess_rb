class ChessRB::Piece
  WP = 1; WN = 2; WLB = 3; WDB = 4; WR = 5; WQ = 6; WK = 7
  BP = 11; BN = 12; BLB = 13; BDB = 14; BR = 15; BQ = 16; BK = 17

  attr_accessor :code

  def initialize(code)
    @code = code
  end

  def type
    self.to_desc[-1, 1]
  end

  def to_desc
    return ChessRB::Piece.constants.select{
      |v| ChessRB::Piece.const_get(v) == @code }[0].to_s
  end

  def to_s(p, d)
    case @code
    when WP
      d ? "♟" : "♙"
    when WN
      d ? "♞" : "♘"
    when WLB
      d ? "♝" : "♗"
    when WDB
      d ? "♝" : "♗"
    when WR
      d ? "♜" : "♖"
    when WQ
      d ? "♛" : "♕"
    when WK
      d ? "♚" : "♔"
    when BP
      d ? "♙" : "♟"
    when BN
      d ? "♘" : "♞"
    when BLB
      d ? "♗" : "♝"
    when BDB
      d ? "♗" : "♝"
    when BR
      d ? "♖" : "♜"
    when BQ
      d ? "♕" : "♛"
    when BK
      d ? "♔" : "♚"
    end
  end
end
