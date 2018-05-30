local WindowUtility = {}

local MutexName = '__mutex'

function WindowUtility.SetMutex(class, mutexValue)
    rawset(class, MutexName, mutexValue)
end

function WindowUtility.ResetMutex(class)
    rawset(class, MutexName, nil)
end

function WindowUtility.GetMutex(class)
    return rawget(class, MutexName)
end

return WindowUtility