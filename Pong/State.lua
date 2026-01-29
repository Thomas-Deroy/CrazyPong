-- =============================================================
-- GLOBAL GAME STATE
-- =============================================================

uiFont = nil
logoImg = nil       
titleScreenImg = nil -- 800x800 Title
endScreenImg = nil   -- 800x800 End Screen

score1, score2 = 0, 0
winnerText = ""
winnerColor = {255, 255, 255}

-- 0=Menu, 1=Playing, 2=GameOver
gameState = 0 
gameMode = 1 
isPaused = false 

-- Chaos
isVertical = false 
isFlipped = false 
eventTimer = 0
rotFlashTimer = 0
currentEventName = "START" 

-- Effects
shakeAmount = 0
shakeDecay = 0.9
particles = {} 
floatingTexts = {} 

gameTimer = MATCH_DURATION

-- Entities
player1 = { x=0, y=0, vx=0, vy=0, w=0, h=0, color=COL_P1, trail={}, buffs={} }
player2 = { x=0, y=0, vx=0, vy=0, w=0, h=0, color=COL_P2, trail={}, buffs={} }
ball = { x=0, y=0, w=BALL_SIZE, h=BALL_SIZE, vx=0, vy=0, trail={} }

-- Powerups
activePowerups = {} 
powerupTimer = 0
powerIcons = {}

-- AI
aiTimer = 0
aiTargetPos = 0
aiCurrentError = 0

-- Input State
lastKeyP1, lastTimeP1 = 0, 0
lastKeyP2, lastTimeP2 = 0, 0

POWER_TYPES = {
    { name="REVERSE", color={150, 0, 255}, duration=5.0, label="R", iconFile="Pong/Assets/Reverse_icon.png" }, 
    { name="AIMBOT",  color={0, 255, 0},   duration=5.0, label="A", iconFile="Pong/Assets/Aimbot_icon.png" }, 
    { name="FREEZE",  color={0, 100, 255}, duration=1.5, label="F", iconFile="Pong/Assets/Freeze_icon.png" }, 
    { name="SPEED",   color={255, 165, 0}, duration=5.0, label="S", iconFile="Pong/Assets/Speed_icon.png" } 
}