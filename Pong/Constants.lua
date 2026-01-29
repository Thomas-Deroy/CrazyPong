-- =============================================================
-- CONFIGURATION & CONSTANTS
-- =============================================================

WINDOW_SIZE = 800
PLAY_AREA_MARGIN = 50 

-- Physics
PADDLE_ACCEL = 8000    
PADDLE_FRICTION = 0.88 
PADDLE_MAX_SPEED = 900 
DASH_IMPULSE = 1500    

PADDLE_LONG_BASE = 120 
PADDLE_SHORT = 20
BALL_SIZE = 16
BALL_SPEED_BASE = 550

EVENT_INTERVAL = 10 
POWERUP_INTERVAL = 10 
MATCH_DURATION = 30 

-- AI Settings
AI_REACTION_TIME = 0.20 
AI_ERROR_MARGIN = 60    

-- Visuals
TRAIL_LENGTH = 8 
IMPACT_WORDS = {"BOUNCE!", "HIT!", "BAM!", "POW!", "SMASH!", "CRASH!"}

-- Colors
COL_P1 = {0, 255, 255}    -- Cyan
COL_P2 = {255, 0, 255}    -- Magenta
COL_BALL = {255, 255, 0}  -- Yellow
COL_BG = {15, 15, 20}     -- Deep Dark Blue

-- Keys
KEY_W, KEY_S, KEY_A, KEY_D = 87, 83, 65, 68
KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT = 38, 40, 37, 39
KEY_SPACE = 32
KEY_R = 82 
KEY_ESC = 27 -- NEW: Pause Key