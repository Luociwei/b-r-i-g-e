#! /usr/bin/env python3
# --*-- coding: utf-8 ---*---

import sys,os,time,math,re
import time
import threading
import datetime

BASE_DIR=os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0,BASE_DIR+'/site-packages/')

from pytz import timezone
import pytz




try:
    import csv
except Exception as e:
    print('e---->',e)

try:
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
except Exception as e:
    print('e---->',e)

try:
    import matplotlib.colors as colors
except Exception as e:
    print('e---->',e)

try:
    from matplotlib.font_manager import FontProperties
except Exception as e:
    print('e---->',e)

try:
    import numpy as np
except Exception as e:
    print('e--->',e)

try:
    import pandas as pd
except Exception as e:
    print('e--->',e)

try:
    import openpyxl
except Exception as e:
    print('import openpyxl error:',e)
try:
    import xlsxwriter
except Exception as e:
    print('import xlsxwriter error:',e)

try:
    import diptest
except Exception as e:
    print('import diptest error:',e)


try:
    import zmq
except Exception as e:
    print('import zmq error:',e)
try:
    import redis
except Exception as e:
    print('import redis error:',e)
# print('python import ----> redis')

print(sys.getdefaultencoding())

redisClient = redis.Redis(host='localhost', port=6379, db=0)

context = zmq.Context()
socket = context.socket(zmq.REP)
socket.setsockopt(zmq.LINGER,0)
socket.bind("tcp://127.0.0.1:3180")

filelogname = '/tmp/CPK_Log/temp/.excel.txt'
filelognamehash = '/tmp/CPK_Log/temp/.excel_hash.txt'


def get_redis_data(zmqMsg):
    tb = redisClient.get(zmqMsg)
    tb_data=[]
    if tb:
        tb=tb.decode('utf-8')
        tb=tb.split("\n")
        tb=(tb[1:-1])   #去掉数据库首尾元素
        for i in tb:
            k=re.sub('\"','',i)  #去掉数据库引号
            h=re.sub(',','',k)   #去掉数据库逗号
            m=h.strip()          #去掉数据库首尾空白
            if is_number(m):
                tb_data.append(eval(m))   #去掉数字的引号
            else:
                tb_data.append(m)
    else:
        tb_data.append('')
    return tb_data

def is_number(s):
    try:
        float(s)
        return True
    except ValueError:
        pass
    try:
        import unicodedata
        unicodedata.numeric(s)
        return True
    except (TypeError, ValueError):
        pass
 
    return False



def get_pst_time():
    date_format=  '%Y-%m-%d' #'%m-%d%Y_%H_%M_%S_%Z'
    date = datetime.datetime.now(tz=pytz.utc)
    date = date.astimezone(timezone('US/Pacific'))
    pstDateTime=date.strftime(date_format)
    return pstDateTime


def excel_hash_to_csv(excel_path,csv_hash_path):
    data = pd.read_excel(excel_path,'ssh',index_col=0,keep_default_na=False)
    data.to_csv(csv_hash_path,encoding='utf-8')

def excel_limitupdate_to_csv(excel_path,csv_limit_path):
    data = pd.read_excel(excel_path,'report',index_col=0,keep_default_na=False)
    data.to_csv(csv_limit_path,encoding='utf-8')


def run(n):

    while True:
        try:
            print("wait for excel client ...")
            zmqMsg = socket.recv()
            socket.send(b'excel.csv')  # socket.send(ret.decode('utf-8').encode('ascii'))
            if len(zmqMsg)>0:
                key = zmqMsg.decode('utf-8')
                print("message from hash client:", key)

                if key == 'excel_hash_to_csv':
                    table_data = get_redis_data(key)
                    if len(table_data)>0:
                        excel_path = table_data[0]
                        csv_hash_path = table_data[1]
                        excel_hash_to_csv(excel_path,csv_hash_path)
                    else:
                        print("---get excel_hash_to_csv error")

                elif key == 'excel_limit_update_to_csv':
                    table_data = get_redis_data(key)
                    if len(table_data)>0:
                        excel_path = table_data[0]
                        csv_limit_path = table_data[1]
                        excel_limitupdate_to_csv(excel_path,csv_limit_path)
                    else:
                        print("---get excel_limit_update_to_csv error")
                        
                
            else:
                time.sleep(0.05)

        except Exception as e:
            print('error excel:',e)

if __name__ == '__main__':
    # t1 = threading.Thread(target=run, args=("<<correlation>>",))
    # t1.start()

    run(0)
    
