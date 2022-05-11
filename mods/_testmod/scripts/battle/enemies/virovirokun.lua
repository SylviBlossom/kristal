local Virovirokun, super = Class("virovirokun", true)

function Virovirokun:init()
    super:init(self)

    if Game:getPartyMember("susie"):getFlag("auto_attack") then
        self:registerAct("Warning")
    end

    self.susie_warned = false

    self.asleep = false
    self.become_red = false

    self:registerAct("Tell Story", "", {"ralsei"})
    self:registerAct("Red", "", {"susie"})
end

function Virovirokun:getSpareText(battler, success)
    local result = super:getSpareText(self, battler, success)
    if not success then
        if type(result) ~= "table" then
            result = {result}
        end
        result[1] = "* " .. battler.chara:getName() .. " spared " .. self.name .. "!\n* But its name wasn't [color:green]GREEN[color:reset]..."
    end
    return result
end

function Virovirokun:mercyFlash(color)
    super:mercyFlash(self, color or {0, 1, 0})
end

function Virovirokun:getNameColors()
    local result = {}
    if self.become_red then
        table.insert(result, {1, 0, 0})
    end
    if self:canSpare() then
        table.insert(result, {0, 1, 0})
    end
    if self.tired then
        table.insert(result, {0, 0.7, 1})
    end
    return result
end

function Virovirokun:onAct(battler, name)
    self.acted_once = true
    if name == "Warning" then
        self.susie_warned = true
        self.comment = "(Warned)"
        return "* You told Virovirokun to watch out for Susie's attacks.[wait:5]\n* It went on guard."
    elseif name == "Tell Story" then
        for _,v in ipairs(Game.battle.enemies) do
            v.asleep = true
            v:setTired(true)
            v.comment = "(Sleepy)"
            v:setScale(4, 2)
            v.text_override = "Zzz..."
        end
        self:addMercy(100)
        return "* Ralsei tells Virovirokun a story.[wait:5]\n* The enemies fell asleep!"
    elseif name == "Red" then
        self.become_red = true
        self:setColor(1, 0, 0)
        return "* You and Susie turned Virovirokun red."
    else
        return super:onAct(self, battler, name)
    end
end

function Virovirokun:getAttackDamage(damage, battler)
    if self.susie_warned and battler.chara.id == "susie" then
        return 0
    else
        return super:getAttackDamage(self, damage, battler)
    end
end

function Virovirokun:getNextWaves()
    if self.asleep then
        return nil
    end
    return super:getNextWaves(self)
end

return Virovirokun