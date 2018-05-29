using LuaInterface;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Utils  {
    /// <summary>
    /// 添加Lua文件
    /// </summary>
    /// <param name="state"></param>
    /// <param name="path"></param>
    public static void AddCustomLuaPath(LuaState state, string path)
    {
        if (!string.IsNullOrEmpty(path))
        {
            state.AddSearchPath(path);
        }
    }
}
