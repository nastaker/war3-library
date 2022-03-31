local trig = CreateTrigger()
local http = require("socket.http")
TriggerRegisterTimerEvent(trig, 0.0, false)
TriggerAddAction(trig, function()
    local u = CreateUnit(Player(0), S2I('nina'), 0.0, 0.0, 0.0)
    DisplayTextToPlayer(GetLocalPlayer(), 0., 0., Id2S(GetUnitTypeId(u)))

    local body, status = http.request("http://nastaker.top:8080/test.php")
    
    DisplayTextToPlayer(GetLocalPlayer(), 0., 0., body..status)
    u = null
end)