# coding=utf-8

import sys
import os

current_dir = os.path.dirname(os.path.realpath(__file__))
print('====>>>>',current_dir+'/site-packages')
sys.path.append(current_dir)

import time
import threading
import zmq
import redis



r = redis.Redis(host='localhost', port=6379, db=0)

context = zmq.Context()
socket = context.socket(zmq.REP)
socket.bind("tcp://127.0.0.1:3110")

def correlation(message):
    print("this function is generate correlation plot......")
    val = r.get(message)
    # time.sleep(5)  #测试python 执行时间 5s
    if val:
        return val
    else:
        return b'None'
        

def run(n):
    while True:
        try:
            print("wait for correlation client ...")
            message = socket.recv()
            print("message from client:", message.decode('utf-8'))
            ret = correlation(message)
            socket.send(ret.decode('utf-8').encode('ascii'))    # socket.send(b"correlation finished")
        except Exception as e:
            print('error:',e)

if __name__ == '__main__':
    t1 = threading.Thread(target=run, args=("<<correlation>>",))
    t1.start()
    
