-- =============================================================
-- DRAWING & EFFECTS
-- =============================================================

function DrawNeonEntity(x, y, w, h, color)
    local r, g, b = color[1], color[2], color[3]
    local ix, iy, iw, ih = math.floor(x), math.floor(y), math.floor(w), math.floor(h)
    
    Engine.SetColor(r, g, b)
    Engine.FillRectAlpha(ix - 5, iy - 5, iw + 10, ih + 10, 30) 
    Engine.FillRectAlpha(ix - 2, iy - 2, iw + 4, ih + 4, 80)  
    Engine.SetColor(255, 255, 255)
    Engine.DrawRect(ix - 1, iy - 1, iw + 2, ih + 2)
    Engine.SetColor(r, g, b)
    Engine.FillRect(ix, iy, iw, ih)
end

function DrawNeonText(str, x, y, color)
    local r, g, b = color[1], color[2], color[3]
    local len = string.len(str)
    local offset = (len * 15) / 2 
    local drawX = math.floor(x - offset)
    local drawY = math.floor(y)
    
    Engine.SetColor(255, 255, 255)
    Engine.DrawString(str, drawX - 1, drawY); Engine.DrawString(str, drawX + 1, drawY) 
    Engine.DrawString(str, drawX, drawY - 1); Engine.DrawString(str, drawX, drawY + 1) 
    Engine.SetColor(r, g, b)
    Engine.DrawString(str, drawX, drawY)
end

function SpawnParticles(x, y, color, count)
    for i = 1, count do
        local angle = math.random() * math.pi * 2
        local speed = math.random(60, 250)
        table.insert(particles, {x=x, y=y, vx=math.cos(angle)*speed, vy=math.sin(angle)*speed, life=1.0, color=color, size=math.random(3,8)})
    end
end

function UpdateTrail(entity)
    table.insert(entity.trail, 1, {x = entity.x, y = entity.y, w = entity.w, h = entity.h})
    if #entity.trail > TRAIL_LENGTH then table.remove(entity.trail) end
end

function DrawTrail(entity, color)
    local r, g, b = color[1], color[2], color[3]
    Engine.SetColor(r, g, b)
    for i, pos in ipairs(entity.trail) do
        local alpha = math.floor(100 * (1 - (i / TRAIL_LENGTH)))
        if alpha > 0 then Engine.FillRectAlpha(math.floor(pos.x), math.floor(pos.y), pos.w, pos.h, alpha) end
    end
end

function SpawnImpactText(x, y, text, color)
    table.insert(floatingTexts, {x=x, y=y, text=text, life=0.8, color=color})
end

function UpdateImpactTexts(dt)
    for i = #floatingTexts, 1, -1 do
        local ft = floatingTexts[i]
        ft.life = ft.life - dt; ft.y = ft.y - (60 * dt)
        if ft.life <= 0 then table.remove(floatingTexts, i) end
    end
end

function DrawImpactTexts(ox, oy)
    for _, ft in ipairs(floatingTexts) do DrawNeonText(ft.text, ft.x + ox, ft.y + oy, ft.color) end
end