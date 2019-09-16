function love.conf(t)
    t.modules.graphics = true
    t.modules.image = true
    t.modules.font = false
    t.modules.sound = false
    t.modules.audio = false
    t.modules.video = false
    t.modules.joystick = false
    t.modules.keyboard = true
    t.modules.mouse = true
    t.modules.touch = false
    t.modules.data = true
    t.modules.math = true
    t.modules.physics = false
    t.modules.system = true
    t.modules.thread = true
    t.modules.event = true
    t.modules.timer = true
    t.modules.window = true -- false for a headless build
 
    t.window.title = "ssg"
    t.window.icon = nil
    t.window.x = nil
    t.window.y = nil
    t.window.width = 400
    t.window.height = 200
    t.window.minwidth = 400
    t.window.minheight = 100
    t.window.borderless = false
    t.window.resizable = true
    t.window.fullscreen = false
    t.window.fullscreentype = "desktop"
    t.window.vsync = 1
    t.window.msaa = 0
    t.window.depth = nil
    t.window.stencil = nil
    t.window.highdpi = false
    t.window.display = 1

    t.audio.mixwithsystem = false -- iOS, Android
    
    t.version = "11.0"
    t.identity = "ssg"
    t.appendidentity = false
    t.console = false -- Windows
    t.accelerometerjoystick = false
    t.externalstorage = true -- Android
    t.gammacorrect = false
end