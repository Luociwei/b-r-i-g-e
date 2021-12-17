#! /usr/bin/env python3
# --*-- coding: utf-8 ---*---

import sys,os



import time
import threading

BASE_DIR=os.path.dirname(os.path.abspath(__file__))
#print('BASE_DIR--->',BASE_DIR)
sys.path.insert(0,BASE_DIR+'/site-packages/')

try:
    import zmq
except Exception as e:
    print('import zmq error:',e)
# print('python import ----> zmg')

try:
    import subprocess
except Exception as e:
    print('import subprocess error:',e)
# print('python import ----> subprocess')

print(sys.getdefaultencoding())



context = zmq.Context()
socket = context.socket(zmq.REP)
socket.bind("tcp://127.0.0.1:3160")




def copy_function(path):
    subprocess.run(["osascript", "-e", 'set the clipboard to (read (POSIX file "' + str(path) + '") as JPEG picture)'])

def run(n):
    while True:
        try:
            print("wait for copy image client ...")
            zmqMsg = socket.recv()
            socket.send(b'copy_sendback')
            if len(zmqMsg)>0:
                keyMsg = zmqMsg.decode('utf-8')
                #print("message from copy client:", keyMsg)
                msg =keyMsg.split("$$")
                if len(msg)>1:
                    if msg[0] == 'copy-image':
                        image_path = msg[1].strip()
                        copy_function(image_path)

            else:
                time.sleep(0.05)
        except Exception as e:
            print('copy error:',e)

if __name__ == '__main__':
    run(0)
    
    
