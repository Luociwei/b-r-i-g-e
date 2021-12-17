import ctypes
from ctypes import *
g_strLibPath ='libVTNotification.dylib'

libPy = ctypes.cdll.LoadLibrary("/usr/local/lib/libVTNotification.dylib")

## void PostMsg(const char * cmsgname,const char * info,int progress,const char * title)
libPy.PostMsg.argtypes =  [ctypes.c_char_p,ctypes.c_char_p,ctypes.c_int,ctypes.c_char_p] 

libPy.PostJsonInfo.argtypes =  [ctypes.c_char_p,ctypes.c_char_p]


def PostProgressMsg(progress,info,title):
    kNotificationShowProgressUp = "kNotification_Show_Progress_Up"
    libPy.PostMsg(kNotificationShowProgressUp.encode(encoding="utf-8"),info.encode(encoding="utf-8"),progress,title.encode(encoding="utf-8"))


def PostJsonInfo(jsoninfo):
    print("PostJsonInfo Start >>")
    kNotificationShowProgressUp = "kNotification_Show_Progress_Up"
    libPy.PostJsonInfo(kNotificationShowProgressUp.encode(encoding="utf-8"),jsoninfo.encode(encoding="utf-8"))
    
    

if __name__ == '__main__':
    PostProgressMsg(50,"coming from python","this is a test")
