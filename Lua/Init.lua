
require "jass.console".enable = true
jass = require "jass.common"

setmetatable(_ENV, {__index = getmetatable(jass).__index})

function S2I(str)
    -- 获取字符串长度
    local len = #str
    -- 当前字符串位置索引
    local index = 1
    -- 保存id值
    local id = 0
    -- 循环
    repeat
        -- 切割字符串，将字符串第一位摘出来，保存到变量c中
        local c = string.sub(str, index, index)
        -- 将c中保存的字符转换为id值，这里为什么是256的次幂，我也不太清楚
        id = id + string.byte(c) * 256^(len - index)
        -- 索引向前前进一位
        index = index + 1
        -- 直至【字符串长度】小于【当前字符串位置】
    until len < index
    -- 返回技能字符串的id
    return id
end

function Id2S(id)
    local str = ""
    local MAX_LEN = 4
    repeat
        local len = 1
        -- 获取最低位数字 公式为：x%pow(256,3)%pow(256,2)%pow(256,1) 
        local temp = id
        while len < MAX_LEN do
            temp = temp%(256^(4-len))
            len = len + 1
        end
        -- 此时temp的值即是最低位数字，将其转为str
        str = string.char(temp/(256^(4-len)))..str
        -- 并从id中减去此temp值
        id = id - temp
        MAX_LEN = MAX_LEN - 1
    until MAX_LEN <= 0
    return str
end