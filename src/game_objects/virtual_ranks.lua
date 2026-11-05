SMODS.VirtualRanks = {}
SMODS.VirtualRank = SMODS.GameObject:extend {
    obj_table = SMODS.VirtualRanks,
    obj_buffer = {},
    set = 'VirtualRank',
    required_params = {
        'key',
        'base_ranks',
    },
    next_redirs = {},
    prev_redirs = {},
    register = function (self)
        if self:check_dependencies() then
            if SMODS.Ranks[self.key] then
                sendWarnMessage(("VirtualRank from '%s' tried to register with existing Rank key '%s'"):format(self.mod.name, self.key), self.set)
                return
            end
            self.obj_table[self.key] = self
            self.obj_buffer[#self.obj_buffer + 1] = self.key
            self.registered = true
        end
    end,
    inject = function(self)
        for rank, _ in pairs(self.base_ranks) do
            if SMODS.Ranks[rank] then
                table.insert(SMODS.Ranks[rank].virtual.ranks, self.key)
            else
                self.base_ranks[rank] = nil
                sendWarnMessage(("VirtualRank from '%s' tried to register with invalid base_rank key '%s'"):format(self.mod.name, self.key), self.set)
            end
        end
        for _, dir in ipairs({"next", "prev"}) do
            for redir_rank, do_redir in pairs(self[dir.."_redirs"]) do
                if SMODS.Ranks[redir_rank] then
                    SMODS.Ranks[redir_rank].virtual[dir] = SMODS.Ranks[redir_rank].virtual[dir] or {}
                    if do_redir then
                        SMODS.Ranks[redir_rank].virtual[dir][self.key] = true
                    else
                        -- Do nothin' because the line before the if statement already guarantees overriding of base .next/.prev
                    end
                end
            end
        end
    end,
    delete = function(self)
        local i
        for j, v in ipairs(self.obj_buffer) do
            if v == self.key then i = j end
        end
        table.remove(self.obj_buffer, i)
    end,
    get_straight_next = function (self, direction, do_wrap)
        local dir = direction == "prev" and "prev" or "next"
        local ret = {}
        for k, v in pairs(self[dir] or {}) do
                ret[k] = v
            end
        if do_wrap then
            for k, v in pairs(self[dir.."_wrap"] or {}) do
                ret[k] = v
            end
        end
        return ret
    end
}

SMODS.VirtualRank {
    key = "Ace_low",
    base_ranks = {Ace = true},
    next = {['2'] = true},
    prev_redirs = {['2'] = true},
    -- next_redirs = {King = false}, -- Technically redundant because of the Ace_high overriding it
    prev_wrap = {King = true},
}
SMODS.VirtualRank {
    key = "Ace_high",
    base_ranks = {Ace = true},
    prev = {King = true},
    next_redirs = {King = true},
    -- prev_redirs = {['2'] = false}, -- Technically redundant because of the Ace_low overriding it
    next_wrap = {['2'] = true},
}