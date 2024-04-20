Config.OXTarget = false

Config.Target = {
    EnterPoint = {
        TargetSize = 2,
        InteractDistance = 5
    },
    ExitPoint = {
        InteractDistance = 3
    },
    MethPoint = {
        TargetSize = 1.2,
        InteractDistance = 1.5
    },
    SlurryPoint = {
        InteractDistance = 1.5
    },
    StoragePoint = {
        InteractDistance = 3
    }

}

Config.Marker = {
    type = 20,
    sizeX = 1.0,
    sizeY = 1.0,
    sizeZ = 1.0,
    r = 255,
    g = 255,
    b = 255,
    a = 100,
    rotate = true,
    distance = 2
}

Config.UsePed = {
    -- If you enable this, the enter marker is replaced with a ped
    Enabled = false,
    Model = 'mp_f_meth_01'
}