extends Node


const STARTING_SECONDS = 45
const SECONDS_PER_POINT = 3

const BLOCK_STATE_UNKNOWN = " "

const BLOCK_STATE_0 = "0"
const BLOCK_STATE_1 = "1"
const BLOCK_STATE_2 = "2"
const BLOCK_STATE_3 = "3"
const BLOCK_STATE_4 = "4"
const BLOCK_STATE_5 = "5"
const BLOCK_STATE_6 = "6"
const BLOCK_STATE_7 = "7"
const BLOCK_STATE_8 = "8"

const BLOCK_STATE_HAZARD = "B"

const BLOCK_STATE_PLAYER_1 = "P1"
const BLOCK_STATE_PLAYER_2 = "P2"


const COLOR_UNKNOWN = Color(0.168627, 0.235294, 0.4)
const COLOR_UNKNOWN_ALT = Color(0.219608, 0.290196, 0.466667)
const COLOR_NUMBER = Color(0.867188, 0.702949, 0.142273)
const COLOR_PLAYER_1 = Color(0.831373, 0.078431, 0.078431)
const COLOR_PLAYER_2 = Color(0.047059, 0.47451, 0.054902)

const YOU_RESIGNED = "You resigned."
const YOUR_OPPONENT_RESIGNED = "Your opponent resigned. You won!"
const YOU_RAN_OUT_OF_TIME = "You ran out of time. You lost."
const YOUR_OPPONENT_RAN_OUT_OF_TIME = "Your opponent ran out of time. You win!"
const YOU_WON = "You won with {x} points!"
const YOU_LOST = "You lost with only {x} points."
