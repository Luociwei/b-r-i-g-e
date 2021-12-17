# coding=utf-8

import sys
# sys.path.append("/Users/RyanGao/Desktop/Python_Redis_Test/Python_Redis_Test/Python/site-packages")

import os
import time
import threading
import zmq
import redis


# context = zmq.Context()
# socket = context.socket(zmq.REQ)
# socket.connect("tcp://127.0.0.1:3100")


# try:
#     print("wait for cpk client ...")
#     socket.send(b'f')
#     message = socket.recv()
#     print("message from cpk client:", message.decode('utf-8'))
# except Exception as e:
#     print('error:',e)
#     sys.exit()



r = redis.Redis(host='localhost', port=6379, db=0)

print("=====s=s=s=====")
r.set('dummy','eeeeeeeee')
# time.sleep(1)

	# print("=====")
    # print(s.decode('utf-8'))
  






    
    




