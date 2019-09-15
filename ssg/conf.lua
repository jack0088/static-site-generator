function love.conf(t)
    t.modules.graphics = true
    t.modules.image = true
    t.modules.font = false
    t.modules.sound = false
    t.modules.audio = false
    t.modules.video = false
    t.modules.joystick = false
    t.modules.keyboard = false
    t.modules.mouse = false
    t.modules.touch = false
    t.modules.data = true
    t.modules.math = true
    t.modules.physics = false
    t.modules.system = true
    t.modules.thread = true
    t.modules.event = true
    t.modules.timer = true
    t.modules.window = true -- false for headless build
end