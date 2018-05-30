using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public sealed class Constant : MonoBehaviour {
    //读取资源的模式 true 表示读取bundle
    public static bool readModel = false;
    //平台
    public static string platform = "Windows";
    //资源根目录
    public static string resPath = "";
    //tolua 自带的lua路径
    public static string luaPath = "";
    //资源bundle 路径
    public static string abPath = "";
}
