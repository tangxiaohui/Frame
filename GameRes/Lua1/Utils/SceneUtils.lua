local SceneUtils = {}

function SceneUtils.GetActiveSceneName()
    local scene = UnityEngine.SceneManagement.SceneManager.GetActiveScene()
    if scene ~= nil and type(scene.name) == "string" then
        return scene.name
    end
    return nil
end

function SceneUtils.LoadScene(name, force)
    
end

return SceneUtils
