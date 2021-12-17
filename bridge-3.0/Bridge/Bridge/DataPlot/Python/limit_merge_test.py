# -*- coding: utf-8 -*-
import os
import sys

BASE_DIR=os.path.dirname(os.path.abspath(__file__))
#print('BASE_DIR--->',BASE_DIR)
sys.path.insert(0,BASE_DIR+'/site-packages/')
import csv
import textwrap
import random
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib
from post import *
matplotlib.use("Agg")
#%matplotlib inline  #not sure what this line does
import numpy as np
import matplotlib.cm as cm

try:
    import zmq
except Exception as e:
    print('import zmq error:',e)
try:
    import redis
except Exception as e:
    print('import redis error:',e)

try:
    from datetime import datetime, timedelta
except Exception as e:
    print('import datetime,timedelta error:',e)

station_id_key = ''
slot_id_key = ''

redisClient = redis.Redis(host='localhost', port=6379, db=0)
context = zmq.Context()
socket = context.socket(zmq.REP)
socket.setsockopt(zmq.LINGER,0)
socket.bind("tcp://127.0.0.1:3192")


def save(afterData,data,csv_data_path):

    data = pd.read_csv(csv_data_path,dtype=object)
    deta = time.strftime("%Y-%m-%d_%H_%M_%S",time.localtime())
    csv_data_path = csv_data_path.replace(".csv","_{}.csv".format(deta))

    data = data.drop(data[data["TESTNAME"].str.contains("//")==True].index)
    data["LOW"] = afterData["LOW"]
    data["HIGH"] = afterData["HIGH"]

    

    data.to_csv(csv_data_path,header=1,index=False) #保存列名

    PostJsonInfo( "finish^&^" + csv_data_path)

def parse_testplan_csv(csv_data_path):

    print("parse_testplan_csv1:", csv_data_path)
    
    #csv_data_path = "/Users/vitoxie/Desktop/data/test_script/20200424_v1__qf_fct.csv"
    data = pd.read_csv(csv_data_path,dtype=object)
    data1 = data


    print(data.columns.values)
    data["Index"]=list(range(1,len(data)+1))

    data = data[["Index","TESTNAME","SUBTESTNAME","SUBSUBTESTNAME","LOW","HIGH"]]
    data["ItemName"] = data["TESTNAME"] +" "+ data["SUBTESTNAME"]+ " " + data["SUBSUBTESTNAME"]
    data =data[["Index","ItemName","LOW","HIGH"]]

    #data = data.drop(data["\\" in data["ItemName"]].index)
    data = data.drop(data[data["ItemName"].str.contains("//")==True].index)

    data1 = data1.drop(data[data["ItemName"].str.contains("//")==True].index)



    data = data.fillna("")

    

    return data.to_json(orient='values'),data,data1
def parse_limit_file(xlsx_data_path):

    print("parse_limit_file:", xlsx_data_path)

    data_limit = pd.read_excel(open(xlsx_data_path, 'rb'),sheet_name="report",dtype=object) 

    data_limit["Index"]=list(range(1,len(data_limit)+1))

    data_limit =data_limit[["Index","Item_name","New LSL","New USL"]]

    data_limit = data_limit.fillna("")

    return data_limit.to_json(orient='values'),data_limit

def caculateIndexInfo(data,data_limit):
    import json
    data["Item_data"] = data["ItemName"]
    data_limit.rename(columns={'Item_name':'ItemName' , 'Index':'Index_limit'}, inplace=True)
    data_limit["Item_limit"] = data_limit["ItemName"]
    comparedata =pd.merge(data,data_limit,on='ItemName',how='outer',indicator=True)


    #new data

    comparedata["Index_new"] = list(range(1,len(comparedata)+1))

    #new_data = comparedata[["Index_new","Item_data","LOW","HIGH"]]
#
    #new_data = new_data.fillna("--").values.tolist()
#
    #new_limit_data = comparedata[["Index_new","Item_limit","New LSL","New USL"]]
#
    #new_limit_data = new_limit_data.fillna("--").values.tolist()


    new_data_merge =  comparedata[["Index_new","Item_data","LOW","HIGH","Item_limit","New LSL","New USL"]]
    new_data_merge = new_data_merge.fillna("--").values.tolist()



    data_only = comparedata[comparedata["_merge"] == 'left_only']

    data_only['Index_new']=data_only['Index_new'].astype('int')

    data_only = data_only["Index_new"]

    red = comparedata[comparedata["_merge"] == 'right_only']

    red['Index_new']=red['Index_new'].astype('int')

    red = red['Index_new']

    bothdata = comparedata[comparedata["_merge"] == 'both']

    bothdata['Index_new']=bothdata['Index_new'].astype('int')

    checkLimitdata =bothdata[['Index_new','LOW','New LSL','HIGH','New USL']]

    green= checkLimitdata[(checkLimitdata["New USL"] == "") & (checkLimitdata["New LSL"] =="") ]['Index_new']

    yellow= checkLimitdata[((checkLimitdata["New USL"] != "") & (checkLimitdata["New USL"] !=checkLimitdata["HIGH"])) |  ((checkLimitdata["New LSL"] != "") & (checkLimitdata["New LSL"] !=checkLimitdata["LOW"])) ]['Index_new']
    
    retDic = {"gray":list(data_only),"red":list(red),"green":list(green),"yellow":list(yellow),"new_data":new_data_merge}

    return json.dumps(retDic)



import time


def run(n):
    testplanjsonObjPath = None
    testplanjsonObjBefore = None
    testplanjsonObj = None
    limitfilejsonObj = None

    while True:
        try:
            print("wait for limit merge client ??...")
            zmqMsg = socket.recv()
            
            print("message from limit merge client:{}".format(zmqMsg))
            socket.send(b'limit_merge_sendback')
            
            if len(zmqMsg)>0:
                keyMsg = zmqMsg.decode('utf-8')
                
                msg =keyMsg.split("$$")
                print("message from limit merge client:", msg)
                if len(msg)>=3:
                    if msg[0] == 'limitmerge':

                        if msg[1] == "profile":
                            testplanjsonObjPath = msg[2]
    
                            testplanjson,testplanjsonObj,testplanjsonObjBefore = parse_testplan_csv(msg[2])

                            PostJsonInfo("profile" + "^&^" + testplanjson)
    
                            
                        elif msg[1] == "limit":
                            print("parse_limit_file1:",msg[2])
                            limitfilejson,limitfilejsonObj = parse_limit_file(msg[2])

                            PostJsonInfo("limit" + "^&^" + limitfilejson)
                            
                            pass
                        elif msg[1]== "both":

                            bothInfo = caculateIndexInfo(testplanjsonObj,limitfilejsonObj)
                            PostJsonInfo("both" + "^&^" + bothInfo)
                if len(msg)>=2 and msg[0] == "save":
                    print("ask for save :", msg)

                    if "null" in msg[1]:
                        PostJsonInfo( "exception^&^" + str("nothing changed !!!"))
                    else:
                        listModify =  msg[1].split(";")
    
                        print("ask for save 1:", listModify,testplanjsonObj,limitfilejsonObj)
    
                    
                        for mapping in listModify:
                            print("ask for save 2:", mapping)
                            indexs =  mapping.split("|")
    
                            print("ask for save 3:", indexs)
    
                            
    
                            testplanjsonObj.iloc[int(indexs[0]),2]  = int(indexs[1])
                            testplanjsonObj.iloc[int(indexs[0]),3]  = int(indexs[2])
    
                        save(testplanjsonObj,testplanjsonObjBefore,testplanjsonObjPath )


            else:
                time.sleep(0.05)
        except Exception as e:
            PostJsonInfo( "exception^&^" + str(e))
            print('error limit merge rate:',e)

if __name__ == '__main__':
    run(0)
    # csv_data_path = "/Users/vitoxie/Desktop/testfolder/J5XX_1124V1_demo3.csv"
    # limitdata_path = "/Users/vitoxie/Desktop/testfolder/Limit_Update_saqib_dummy_For_lmt_2021-06-01.xlsx"
    # _,data,_ = parse_testplan_csv(csv_data_path)
    # _ ,data_limit = parse_limit_file(limitdata_path)

    # caculateIndexInfo(data,data_limit)





