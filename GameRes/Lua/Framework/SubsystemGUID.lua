
-- 后面的值是截取 GUID 第一段数据, 所以能保证在这种使用情况下是唯一的
local subsystemGuids = {
    ['ScheduleManager'] = 0x936d57a7,
    ['UIManager'] = 0x5c38ecf6,
    ['SceneManager'] = 0x025a5883,
    ['EventManager'] = 0x5d62ad56,
    ['LocalDataManager'] = 0x6f7af82f,
    ['AudioManager'] = 0x36a06255,
    ['VideoPlayerManager'] = 0x14f2de92,

    -- cos3d
    ['TimeManager'] = 0x628f4cfb,
    ['WindowManager'] = 0xd8e54336,
    ['PersistentWindowManager'] = 0xe7fbcec1,
    ['DataCacheManager'] = 0x5a15f5a0,
    ['Network'] = 0x270a1068,
    ['GuideManager'] = 0xd1b56875,
    ['SDKManager'] = 0x404daa91,

    ['PoolManager'] = 0x9fd72c7a,
    ['SystemGuideManager'] = 0xf8a6c8f9
}

return subsystemGuids