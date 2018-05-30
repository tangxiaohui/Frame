using LuaInterface;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AppManager : MonoBehaviour
{
    private static AppManager instance;
    private LuaState luaState;

    public static AppManager Instance
    {
        get
        {
            return instance;
        }
    }

    private void Awake()
    {
        instance = this;
        DontDestroyOnLoad(this.gameObject);
    }
    void Start()
    {
        Initialize();

    }
    /// <summary>
    /// 初始化平台
    /// </summary>
    void Initialize()
    {
        //初始化平台
        InitializePlatform();
        //初始化资源相关路径
        InitializePath();
        //初始化相关资源
        InitilaizeRes();
    }

    #region 初始化平台
    /// <summary>
    /// 初始化平台
    /// </summary>
    public void InitializePlatform()
    {
#if WINDOWS_BUILD || UNITY_STANDALONE
        Constant.platform = "Windows";
#elif UNITY_ANDROID
        Constant.platform = "Android";
#elif UNITY_IOS
        Constant.platform = "iOS";
#endif

    }
    #endregion
    #region 初始化不同平台的相关路径
    void InitializePath()
    {
#if UNITY_STANDALONE || UNITY_EDITOR
        Constant.resPath = Application.dataPath + "/../../GameRes/Lua";
        Constant.luaPath = Constant.resPath + "/Lua";
        Constant.abPath = Constant.resPath + "/AssetBundles/Windows/";
#endif
    }
    #endregion
    #region 初始化相关资源
    void InitilaizeRes()
    {
        CheckNeedUpdate();
        StartCoroutine(InitializeToLua());

    }
    #endregion

    /// <summary>
    /// 检测是否要更新
    /// </summary>
    public void CheckNeedUpdate()
    {

    }

    IEnumerator InitializeToLua()
    {
        luaState = new LuaState();
        Utils.AddCustomLuaPath(luaState, GetCustomLuaPath());
        luaState.Start();
        LuaBinder.Bind(luaState);
        LuaManager.Instance.Init(luaState);
        LuaManager.Instance.CallGameStart();
        yield return null;
    }
    private string GetCustomLuaPath()
    {
#if WINDOWS_BUILD
        return Application.dataPath + "/../GameRes/Lua";
#else
        return null;
#endif
    }

    private void Update()
    {
      //  Debug.Log(LuaManager.Instance.gameUpdate);
        LuaManager.Instance.gameUpdate.Call();

    }

}
