
local ProgressBarUtils = {}

function ProgressBarUtils.Display(title, info, progress)
    _G.ProgressBarCtrl.Instance:Display(title, info, progress)
end

function ProgressBarUtils.Clear()
    _G.ProgressBarCtrl.Instance:Clear()
end

return ProgressBarUtils
