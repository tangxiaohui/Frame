
using UnityEngine;
using LuaInterface;
using System;

public sealed class LuaManager  {



    static LuaManager instance;

    private LuaState luaState;
    LuaLooper luaLooper;
    #region Mono functions
    LuaFunction _gameStart;
    LuaFunction _gameFixedUpdate;
    public LuaFunction gameUpdate;
    LuaFunction _gameLateUpdate;
    LuaFunction _gameOnFocus;
    LuaFunction _gameOnPause;
    LuaFunction _gameOnQuit;
    LuaFunction _gameOnSceneLoaded;

    public static LuaManager Instance
    {
        get
        {
            if (instance == null)
                instance = new LuaManager();
            return instance;
        }
    }
    #endregion
    public void Init(LuaState luaState)
    {
        if (luaState == null)
            new ArgumentNullException("luaState is Null!");
        this.luaState = luaState;
        OpenLibs();
        luaState.LuaSetTop(0);
        SetupLuaLooper();
        luaState.DoFile("Init.lua");
        BindFunctions();


    }

    public void CallGameStart()
    {
        if (_gameStart != null)
            _gameStart.Call();
    }
    /// <summary>
    /// 绑定需要的各种方法
    /// </summary>
    void BindFunctions()
    {
        BindMonoFunctions();
    }
    void BindMonoFunctions()
    {
        _gameStart = luaState.GetFunction("_G.Start");
        _gameFixedUpdate = luaState.GetFunction("_G.FixedUpdate");
        gameUpdate = luaState.GetFunction("_G.Update");
        _gameLateUpdate = luaState.GetFunction("_G.LateUpdate");
        _gameOnFocus = luaState.GetFunction("_G.OnApplicationFocus");
        _gameOnPause = luaState.GetFunction("_G.OnApplicationPause");
        _gameOnQuit = luaState.GetFunction("_G.OnApplicationQuit");
        _gameOnSceneLoaded = luaState.GetFunction("_G.OnSceneLoaded");
    }
    /// <summary>
    /// 添加脚本开始循环
    /// </summary>
    void SetupLuaLooper()
    {
        luaLooper = AppManager.Instance.gameObject.AddComponent<LuaLooper>();
        luaLooper.luaState = luaState;
    }
    void OpenLibs()
    {
        luaState.OpenLibs(LuaDLL.luaopen_pb);
        //luaState.OpenLibs(LuaDLL.luaopen_sproto_core);
        //luaState.OpenLibs(LuaDLL.luaopen_protobuf_c);
        //luaState.OpenLibs(LuaDLL.luaopen_lpeg);
        //luaState.OpenLibs(LuaDLL.luaopen_bit);
        luaState.OpenLibs(LuaDLL.luaopen_socket_core);
        OpenCJson();
        OpenLuaSocket();
    }
    //cjson 比较特殊，只new了一个table，没有注册库，这里注册一下
    void OpenCJson()
    {
        luaState.LuaGetField(LuaIndexes.LUA_REGISTRYINDEX, "_LOADED");
        luaState.OpenLibs(LuaDLL.luaopen_cjson);
        luaState.LuaSetField(-2, "cjson");

        luaState.OpenLibs(LuaDLL.luaopen_cjson_safe);
        luaState.LuaSetField(-2, "cjson.safe");
    }

    void OpenLuaSocket()
    {
        LuaConst.openLuaSocket = true;

        luaState.BeginPreLoad();
        luaState.RegFunction("socket.core", LuaOpen_Socket_Core);
        luaState.EndPreLoad();
    }

    #region luaide 调试库添加

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    static int LuaOpen_Socket_Core(IntPtr L)
    {
        return LuaDLL.luaopen_socket_core(L);
    }
    #endregion

}
