-- =============================================================
-- GAME LOGIC, PHYSICS & AI
-- =============================================================

function GetPaddleSize(myScore, oppScore)
    local diff = oppScore - myScore
    local factor = 1.0 + (diff * 0.05)
    if factor < 0.90 then factor = 0.90 end
    if factor > 1.10 then factor = 1.10 end
    return math.floor(PADDLE_LONG_BASE * factor)
end

function CheckCollision(a, b)
    return a.x < b.x + b.w and a.x + a.w > b.x and a.y < b.y + b.h and a.y + a.h > b.y
end

function SpawnPowerup()
    local size = 30
    local px = math.random(100, WINDOW_SIZE - 100)
    local py = math.random(100, WINDOW_SIZE - 100)
    local typeIdx = math.random(1, #POWER_TYPES)
    table.insert(activePowerups, {
        x = px, y = py, w = size, h = size,
        type = POWER_TYPES[typeIdx],
        pulse = 0
    })
end

function ApplyPowerup(picker, opponent, type)
    SpawnImpactText(picker.x, picker.y, type.name .. "!", type.color)
    picker.buffs[type.name] = nil
    opponent.buffs[type.name] = nil
    if type.name == "REVERSE" then opponent.buffs["REVERSE"] = type.duration 
    elseif type.name == "FREEZE" then opponent.buffs["FREEZE"] = type.duration 
    elseif type.name == "AIMBOT" then picker.buffs["AIMBOT"] = type.duration    
    elseif type.name == "SPEED" then picker.buffs["SPEED"] = type.duration end
end

function ResetBall(scorer)
    ball.x = WINDOW_SIZE/2 - BALL_SIZE/2
    ball.y = WINDOW_SIZE/2 - BALL_SIZE/2
    ball.trail = {}
    local speed = BALL_SPEED_BASE
    if isVertical then
        local dir = (scorer == 1) and -1 or 1 
        ball.vy = speed * dir
        ball.vx = (math.random() * 2 - 1) * (speed * 0.6)
    else
        local dir = (scorer == 1) and 1 or -1 
        ball.vx = speed * dir
        ball.vy = (math.random() * 2 - 1) * (speed * 0.6)
    end
    shakeAmount = 20
end

function UpdateOrientation()
    local pW, pH
    if isVertical then pW, pH = PADDLE_LONG_BASE, PADDLE_SHORT
    else pW, pH = PADDLE_SHORT, PADDLE_LONG_BASE end
    
    if isVertical then
        if not isFlipped then
            player1.x = WINDOW_SIZE/2 - pW/2; player1.y = WINDOW_SIZE - PLAY_AREA_MARGIN - pH
            player2.x = WINDOW_SIZE/2 - pW/2; player2.y = PLAY_AREA_MARGIN
        else
            player1.x = WINDOW_SIZE/2 - pW/2; player1.y = PLAY_AREA_MARGIN
            player2.x = WINDOW_SIZE/2 - pW/2; player2.y = WINDOW_SIZE - PLAY_AREA_MARGIN - pH
        end
    else
        if not isFlipped then
            player1.x = PLAY_AREA_MARGIN; player1.y = WINDOW_SIZE/2 - pH/2
            player2.x = WINDOW_SIZE - PLAY_AREA_MARGIN - pW; player2.y = WINDOW_SIZE/2 - pH/2
        else
            player1.x = WINDOW_SIZE - PLAY_AREA_MARGIN - pW; player1.y = WINDOW_SIZE/2 - pH/2
            player2.x = PLAY_AREA_MARGIN; player2.y = WINDOW_SIZE/2 - pH/2
        end
    end
    
    player1.vx, player1.vy = 0, 0
    player2.vx, player2.vy = 0, 0
    player1.trail = {}; player2.trail = {}
    
    ResetBall(math.random(1,2))
end

function TriggerChaosEvent()
    local roll = math.random(1, 3)
    if roll == 1 then isVertical = not isVertical; isFlipped = false; currentEventName = "ROTATION!"
    elseif roll == 2 then isFlipped = not isFlipped; currentEventName = "SIDE SWAP!"
    else isVertical = not isVertical; isFlipped = not isFlipped; currentEventName = "CHAOS FLIP!" end
    rotFlashTimer = 1.0; shakeAmount = 30
    UpdateOrientation()
end

function StartMatch(mode)
    score1, score2 = 0, 0
    gameTimer = MATCH_DURATION
    isGameOver = false
    gameState = 1
    gameMode = mode
    isVertical = false; isFlipped = false
    eventTimer = 0; powerupTimer = 0
    currentEventName = "START"
    activePowerups = {}
    player1.buffs = {}; player2.buffs = {}
    aiTimer = 0; aiCurrentError = 0
    UpdateOrientation()
    isPaused = false
end