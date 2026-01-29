-- =============================================================
-- NEON PONG: ULTIMATE (PAUSE & TITLE UPDATE)
-- =============================================================

require "Pong/Constants"
require "Pong/State"
require "Pong/Visuals"
require "Pong/Logic"

function Initialize()
    Engine.SetTitle("NEON PONG: ULTIMATE")
    Engine.SetWidth(WINDOW_SIZE)
    Engine.SetHeight(WINDOW_SIZE)
    Engine.SetFrameRate(60)
    
    -- Register Keys: WSAD, R, Space, 1, 2, Arrows, ESC(27)
    local keys = "WSADR 12" .. string.char(37) .. string.char(38) .. string.char(39) .. string.char(40) .. string.char(27)
    Engine.SetKeyList(keys)
    
    -- Load Assets
    Font.LoadFile("Pong/Assets/PixelEmulator-xq08.ttf")
    uiFont = Font.new("Pixel Emulator", true, false, false, 32)
    Engine.SetFont(uiFont)
    
    -- Load Images
    if pcall(function() titleScreenImg = Bitmap.new("Pong/Assets/TitleScreen.png") end) then else titleScreenImg = nil end
    if pcall(function() endScreenImg = Bitmap.new("Pong/Assets/EndScreen.png") end) then else endScreenImg = nil end
    if pcall(function() logoImg = Bitmap.new("Pong/Assets/Title.png") end) then else logoImg = nil end
    
    -- Load Icons
    for _, pType in ipairs(POWER_TYPES) do
        local status, bmp = pcall(function() return Bitmap.new(pType.iconFile) end)
        if status and bmp then powerIcons[pType.name] = bmp else powerIcons[pType.name] = nil end
    end
    
    gameState = 0 
end

function OnKeyPressed(key)
    -- MENU: Selection
    if gameState == 0 then
        if key == 49 then StartMatch(1) end -- 1
        if key == 50 then StartMatch(2) end -- 2
        return
    end

    -- GAME OVER: Reset
    if gameState == 2 then
        if key == KEY_R then 
            gameState = 0 -- Go back to Menu
        end
        return
    end

    -- GAMEPLAY: Pause
    if key == KEY_ESC then 
        isPaused = not isPaused 
    end
    
    if isPaused then return end
    
    -- GAMEPLAY: Reset
    if key == KEY_R then 
        gameState = 0 -- Force quit to Menu
    end

    -- GAMEPLAY: Dash Logic
    local timeNow = os.clock()
    -- P1 Dash
    if key == 87 or key == 83 or key == 65 or key == 68 then 
        if key == lastKeyP1 and (timeNow - lastTimeP1) < 0.25 then
            local dx, dy = 0, 0
            if key == 87 then dy=-1 elseif key == 83 then dy=1 elseif key == 65 then dx=-1 elseif key == 68 then dx=1 end
            if isVertical then player1.vx = player1.vx + (dx * DASH_IMPULSE) else player1.vy = player1.vy + (dy * DASH_IMPULSE) end
            SpawnImpactText(player1.x + player1.w/2, player1.y, "DASH!", COL_P1)
            SpawnParticles(player1.x, player1.y, COL_P1, 10)
        end
        lastKeyP1 = key; lastTimeP1 = timeNow
    end
    -- P2 Dash
    if gameMode == 1 and (key == 37 or key == 38 or key == 39 or key == 40) then 
        if key == lastKeyP2 and (timeNow - lastTimeP2) < 0.25 then
            local dx, dy = 0, 0
            if key == 38 then dy=-1 elseif key == 40 then dy=1 elseif key == 37 then dx=-1 elseif key == 39 then dx=1 end
            if isVertical then player2.vx = player2.vx + (dx * DASH_IMPULSE) else player2.vy = player2.vy + (dy * DASH_IMPULSE) end
            SpawnImpactText(player2.x + player2.w/2, player2.y, "DASH!", COL_P2)
            SpawnParticles(player2.x, player2.y, COL_P2, 10)
        end
        lastKeyP2 = key; lastTimeP2 = timeNow
    end
end

function Tick(dt)
    if gameState == 0 or gameState == 2 or isPaused then return end

    -- Timers
    gameTimer = gameTimer - dt
    if gameTimer <= 0 then 
        gameTimer = 0; gameState = 2 
        if score1 > score2 then winnerText="PLAYER 1 WINS!"; winnerColor=COL_P1 
        elseif score2 > score1 then winnerText="PLAYER 2 WINS!"; winnerColor=COL_P2 
        else winnerText="DRAW!"; winnerColor={255,255,255} end
    end

    eventTimer = eventTimer + dt; if eventTimer >= EVENT_INTERVAL then eventTimer = 0; TriggerChaosEvent() end
    powerupTimer = powerupTimer + dt; if powerupTimer >= POWERUP_INTERVAL then powerupTimer = 0; SpawnPowerup() end
    
    rotFlashTimer = rotFlashTimer - dt
    if shakeAmount > 0 then shakeAmount = shakeAmount * shakeDecay; if shakeAmount < 0.5 then shakeAmount = 0 end end

    -- Update Buffs
    for k, v in pairs(player1.buffs) do player1.buffs[k]=v-dt; if player1.buffs[k]<=0 then player1.buffs[k]=nil end end
    for k, v in pairs(player2.buffs) do player2.buffs[k]=v-dt; if player2.buffs[k]<=0 then player2.buffs[k]=nil end end

    -- Sizing & Physics
    local sizeP1, sizeP2 = GetPaddleSize(score1, score2), GetPaddleSize(score2, score1)
    if isVertical then player1.w,player1.h=sizeP1,PADDLE_SHORT; player2.w,player2.h=sizeP2,PADDLE_SHORT else player1.w,player1.h=PADDLE_SHORT,sizeP1; player2.w,player2.h=PADDLE_SHORT,sizeP2 end

    -- MOVEMENT INPUT & AI (Logic imported from previous steps)
    local p1Input, p2Input = 0, 0
    if not player1.buffs["FREEZE"] then
        if player1.buffs["AIMBOT"] then
            local t = (isVertical) and ball.x or ball.y; local s = (isVertical) and player1.x+player1.w/2 or player1.y+player1.h/2
            if t < s-10 then p1Input=-1 elseif t > s+10 then p1Input=1 end
        else
            local l, r = -1, 1; if player1.buffs["REVERSE"] then l=1; r=-1 end
            if isVertical then if Engine.IsKeyDown(KEY_A) then p1Input=l end; if Engine.IsKeyDown(KEY_D) then p1Input=r end
            else if Engine.IsKeyDown(KEY_W) then p1Input=l end; if Engine.IsKeyDown(KEY_S) then p1Input=r end end
        end
    end
    if not player2.buffs["FREEZE"] then
        if gameMode == 2 then -- AI
            aiTimer=aiTimer+dt; if aiTimer>=AI_REACTION_TIME then aiTimer=0; aiCurrentError=(math.random()*AI_ERROR_MARGIN*2)-AI_ERROR_MARGIN; if player2.buffs["REVERSE"] then aiCurrentError=aiCurrentError*-2 end; aiTargetPos=((isVertical) and ball.x or ball.y)+aiCurrentError end
            local s = (isVertical) and player2.x+player2.w/2 or player2.y+player2.h/2
            if aiTargetPos < s-10 then p2Input=-1 elseif aiTargetPos > s+10 then p2Input=1 end
        else -- Human P2
            local l, r = -1, 1; if player2.buffs["REVERSE"] then l=1; r=-1 end
            if isVertical then if Engine.IsKeyDown(KEY_LEFT) then p2Input=l end; if Engine.IsKeyDown(KEY_RIGHT) then p2Input=r end
            else if Engine.IsKeyDown(KEY_UP) then p2Input=l end; if Engine.IsKeyDown(KEY_DOWN) then p2Input=r end end
        end
    end

    local sm1 = player1.buffs["SPEED"] and 1.5 or 1.0; local sm2 = player2.buffs["SPEED"] and 1.5 or 1.0
    if isVertical then
        player1.vx=(player1.vx*PADDLE_FRICTION)+(p1Input*PADDLE_ACCEL*dt*sm1); player2.vx=(player2.vx*PADDLE_FRICTION)+(p2Input*PADDLE_ACCEL*dt*sm2)
        if math.abs(player1.vx)>PADDLE_MAX_SPEED then player1.vx=(player1.vx>0 and 1 or -1)*PADDLE_MAX_SPEED end
        if math.abs(player2.vx)>PADDLE_MAX_SPEED then player2.vx=(player2.vx>0 and 1 or -1)*PADDLE_MAX_SPEED end
        player1.x=player1.x+player1.vx*dt; player2.x=player2.x+player2.vx*dt
        if player1.x<0 then player1.x=0; player1.vx=0 elseif player1.x>WINDOW_SIZE-player1.w then player1.x=WINDOW_SIZE-player1.w; player1.vx=0 end
        if player2.x<0 then player2.x=0; player2.vx=0 elseif player2.x>WINDOW_SIZE-player2.w then player2.x=WINDOW_SIZE-player2.w; player2.vx=0 end
    else
        player1.vy=(player1.vy*PADDLE_FRICTION)+(p1Input*PADDLE_ACCEL*dt*sm1); player2.vy=(player2.vy*PADDLE_FRICTION)+(p2Input*PADDLE_ACCEL*dt*sm2)
        if math.abs(player1.vy)>PADDLE_MAX_SPEED then player1.vy=(player1.vy>0 and 1 or -1)*PADDLE_MAX_SPEED end
        if math.abs(player2.vy)>PADDLE_MAX_SPEED then player2.vy=(player2.vy>0 and 1 or -1)*PADDLE_MAX_SPEED end
        player1.y=player1.y+player1.vy*dt; player2.y=player2.y+player2.vy*dt
        if player1.y<0 then player1.y=0; player1.vy=0 elseif player1.y>WINDOW_SIZE-player1.h then player1.y=WINDOW_SIZE-player1.h; player1.vy=0 end
        if player2.y<0 then player2.y=0; player2.vy=0 elseif player2.y>WINDOW_SIZE-player2.h then player2.y=WINDOW_SIZE-player2.h; player2.vy=0 end
    end

    -- Ball & Collisions
    ball.x=ball.x+ball.vx*dt; ball.y=ball.y+ball.vy*dt
    UpdateTrail(ball); UpdateTrail(player1); UpdateTrail(player2)

    for i=#activePowerups,1,-1 do
        local pu=activePowerups[i]; pu.pulse=pu.pulse+dt
        if CheckCollision(ball, pu) then
            local d1=math.abs(player1.x-pu.x)+math.abs(player1.y-pu.y); local d2=math.abs(player2.x-pu.x)+math.abs(player2.y-pu.y)
            if d1<d2 then ApplyPowerup(player1,player2,pu.type) else ApplyPowerup(player2,player1,pu.type) end
            table.remove(activePowerups,i)
        end
    end

    if isVertical then
        if ball.x<0 then ball.x=0; ball.vx=-ball.vx; SpawnParticles(0,ball.y,{255,255,255},5); SpawnImpactText(0,ball.y,"BOUNCE!",{200,200,200})
        elseif ball.x>WINDOW_SIZE-ball.w then ball.x=WINDOW_SIZE-ball.w; ball.vx=-ball.vx; SpawnParticles(WINDOW_SIZE,ball.y,{255,255,255},5); SpawnImpactText(WINDOW_SIZE,ball.y,"BOUNCE!",{200,200,200}) end
        if ball.y<-50 then if not isFlipped then score1=score1+1 else score2=score2+1 end; SpawnParticles(ball.x,0,COL_P1,40); ResetBall(1)
        elseif ball.y>WINDOW_SIZE+50 then if not isFlipped then score2=score2+1 else score1=score1+1 end; SpawnParticles(ball.x,WINDOW_SIZE,COL_P2,40); ResetBall(2) end
    else
        if ball.y<0 then ball.y=0; ball.vy=-ball.vy; SpawnParticles(ball.x,0,{255,255,255},5); SpawnImpactText(ball.x,0,"BOUNCE!",{200,200,200})
        elseif ball.y>WINDOW_SIZE-ball.h then ball.y=WINDOW_SIZE-ball.h; ball.vy=-ball.vy; SpawnParticles(ball.x,WINDOW_SIZE,{255,255,255},5); SpawnImpactText(ball.x,WINDOW_SIZE,"BOUNCE!",{200,200,200}) end
        if ball.x<-50 then if not isFlipped then score2=score2+1 else score1=score1+1 end; SpawnParticles(0,ball.y,COL_P2,40); ResetBall(2)
        elseif ball.x>WINDOW_SIZE+50 then if not isFlipped then score1=score1+1 else score2=score2+1 end; SpawnParticles(WINDOW_SIZE,ball.y,COL_P1,40); ResetBall(1) end
    end

    if CheckCollision(ball, player1) then
        shakeAmount=10; SpawnParticles(ball.x,ball.y,COL_P1,15); SpawnImpactText(ball.x,ball.y,IMPACT_WORDS[math.random(1,#IMPACT_WORDS)],COL_P1)
        if isVertical then if player1.y>WINDOW_SIZE/2 then ball.y=player1.y-ball.h-1; ball.vy=-math.abs(ball.vy)*1.05 else ball.y=player1.y+player1.h+1; ball.vy=math.abs(ball.vy)*1.05 end; ball.vx=ball.vx+(ball.x+ball.w/2-(player1.x+player1.w/2))*5
        else if player1.x<WINDOW_SIZE/2 then ball.x=player1.x+player1.w+1; ball.vx=math.abs(ball.vx)*1.05 else ball.x=player1.x-ball.w-1; ball.vx=-math.abs(ball.vx)*1.05 end; ball.vy=ball.vy+(ball.y+ball.h/2-(player1.y+player1.h/2))*5 end
    end
    if CheckCollision(ball, player2) then
        shakeAmount=10; SpawnParticles(ball.x,ball.y,COL_P2,15); SpawnImpactText(ball.x,ball.y,IMPACT_WORDS[math.random(1,#IMPACT_WORDS)],COL_P2)
        if isVertical then if player2.y>WINDOW_SIZE/2 then ball.y=player2.y-ball.h-1; ball.vy=-math.abs(ball.vy)*1.05 else ball.y=player2.y+player2.h+1; ball.vy=math.abs(ball.vy)*1.05 end; ball.vx=ball.vx+(ball.x+ball.w/2-(player2.x+player2.w/2))*5
        else if player2.x<WINDOW_SIZE/2 then ball.x=player2.x+player2.w+1; ball.vx=math.abs(ball.vx)*1.05 else ball.x=player2.x-ball.w-1; ball.vx=-math.abs(ball.vx)*1.05 end; ball.vy=ball.vy+(ball.y+ball.h/2-(player2.y+player2.h/2))*5 end
    end

    for i=#particles,1,-1 do local p=particles[i]; p.x=p.x+p.vx*dt; p.y=p.y+p.vy*dt; p.life=p.life-dt*2; if p.life<=0 then table.remove(particles,i) end end
    UpdateImpactTexts(dt)
end

function Paint()
    local ox = (math.random()*shakeAmount)-(shakeAmount/2); local oy = (math.random()*shakeAmount)-(shakeAmount/2)
    local cx, cy = WINDOW_SIZE/2, WINDOW_SIZE/2

    -- MAIN MENU 
    if gameState == 0 then
        Engine.SetColor(0,0,0)
        Engine.FillRect(0, 0, WINDOW_SIZE, WINDOW_SIZE)
        if titleScreenImg then Engine.DrawBitmap(titleScreenImg, 0, 0)
        else DrawNeonText("CRAZY PONG", cx, cy-100, COL_P1) end
    
        return
    end

    -- GAMEPLAY BG
    local pulse = math.abs(math.sin(os.clock()*2))*10
    Engine.SetColor(math.floor(COL_BG[1]), math.floor(COL_BG[2]), math.floor(COL_BG[3]+pulse)); Engine.FillRect(0,0,WINDOW_SIZE,WINDOW_SIZE)
    if rotFlashTimer > 0 then Engine.SetColor(255,255,255); Engine.FillRectAlpha(0,0,WINDOW_SIZE,WINDOW_SIZE,math.floor(rotFlashTimer*300)) end
    
    -- BACKGROUND LOGO
    if logoImg then 
        local w, h = logoImg:GetWidth(), logoImg:GetHeight()
        Engine.DrawBitmap(logoImg, math.floor(cx-w/2+ox), math.floor(cy-h/1.8+oy)) 
    end

    for _, pu in ipairs(activePowerups) do
        local ps = math.sin(pu.pulse * 5) * 5
        DrawNeonEntity(pu.x - ps/2 + ox, pu.y - ps/2 + oy, pu.w + ps, pu.h + ps, pu.type.color)
        local icon = powerIcons[pu.type.name]
        if icon then
            local iconSize = 35 + ps 
            Engine.DrawBitmapRect(icon, math.floor(pu.x+pu.w/2 - iconSize/2 + ox), math.floor(pu.y+pu.h/2 - iconSize/2 + oy), 0, 0, 50, 50, math.floor(iconSize), math.floor(iconSize))
        else
            DrawNeonText(pu.type.label, pu.x + pu.w/2 + ox, pu.y + pu.h/2 - 10 + oy, {255,255,255})
        end
    end

    local barY = cy+30+oy; local rem = 1.0-(eventTimer/EVENT_INTERVAL); local barW = math.floor(300*rem)
    Engine.SetColor(rem>0.5 and 0 or 255, rem>0.2 and 255 or 0, 0); Engine.FillRect(math.floor(cx-barW/2+ox), math.floor(barY), barW, 4)
    local min=math.floor(gameTimer/60); local sec=math.floor(gameTimer%60)
    DrawNeonText(string.format("%02d:%02d",min,sec), cx-5+ox, barY+20, {200,200,200})
    if rotFlashTimer > 0.2 then DrawNeonText(currentEventName, cx-10+ox, cy+80+oy, {255,255,0}) end

    if isVertical then if not isFlipped then DrawNeonText(tostring(score2), cx+ox, cy-250+oy, COL_P2); DrawNeonText(tostring(score1), cx+ox, cy+220+oy, COL_P1) else DrawNeonText(tostring(score1), cx+ox, cy-250+oy, COL_P1); DrawNeonText(tostring(score2), cx+ox, cy+220+oy, COL_P2) end else if not isFlipped then DrawNeonText(tostring(score1), cx-250+ox, cy-15+oy, COL_P1); DrawNeonText(tostring(score2), cx+250+ox, cy-15+oy, COL_P2) else DrawNeonText(tostring(score2), cx-250+ox, cy-15+oy, COL_P2); DrawNeonText(tostring(score1), cx+250+ox, cy-15+oy, COL_P1) end end

    DrawTrail(player1, COL_P1); DrawTrail(player2, COL_P2); DrawTrail(ball, COL_BALL)
    
    local c1=COL_P1; if player1.buffs["SPEED"] then c1={255,165,0} elseif player1.buffs["FREEZE"] then c1={0,0,255} end
    DrawNeonEntity(player1.x+ox, player1.y+oy, player1.w, player1.h, c1)
    if player1.buffs["REVERSE"] then DrawNeonText("?", player1.x+player1.w/2+ox, player1.y+oy-20, {255,0,255}) end

    local c2=COL_P2; if player2.buffs["SPEED"] then c2={255,165,0} elseif player2.buffs["FREEZE"] then c2={0,0,255} end
    DrawNeonEntity(player2.x+ox, player2.y+oy, player2.w, player2.h, c2)
    if player2.buffs["REVERSE"] then DrawNeonText("?", player2.x+player2.w/2+ox, player2.y+oy-20, {255,0,255}) end

    DrawNeonEntity(ball.x+ox, ball.y+oy, ball.w, ball.h, COL_BALL)

    for _, p in ipairs(particles) do Engine.SetColor(p.color[1],p.color[2],p.color[3]); Engine.FillRectAlpha(math.floor(p.x+ox), math.floor(p.y+oy), p.size, p.size, math.floor(p.life*255)) end
    DrawImpactTexts(ox, oy)

    if gameState == 2 then
        Engine.SetColor(0,0,0); Engine.FillRect(0,0,WINDOW_SIZE,WINDOW_SIZE)
        if endScreenImg then Engine.DrawBitmap(endScreenImg, 0, 0) end
        DrawNeonText(winnerText, cx+ox-10, cy+oy, winnerColor);
    elseif isPaused then
        Engine.SetColor(0,0,0); Engine.FillRectAlpha(0,0,WINDOW_SIZE,WINDOW_SIZE,255)
        if logoImg then Engine.DrawBitmap(logoImg, math.floor(cx-logoImg:GetWidth()/2), math.floor(cy-logoImg:GetHeight()/1.8)) end
        DrawNeonText("PAUZE", cx-15, cy+40, {255,255,255})
    end
end