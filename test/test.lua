return function (module,require)
    local springPY = {3,18,80,0,0,0}
    local this = module.New(unpack(springPY))
    this:InitResolver()
    local timer = require("timer")
    local count = 0
    local interval
    interval = timer.setInterval(100,function()
        count = count + 1
        if count > 120 then
            timer.clearInterval(interval)
            if math.floor(this:GetOffset()+0.5) == 100 then
                os.exit(0)
                return
            end
            os.exit(1)
            return
        end
        print(this:GetOffset())
    end)
    this:SetGoal(100)
end