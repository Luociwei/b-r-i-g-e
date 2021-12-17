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

import re
try:
    import pytz
except Exception as e:
    print('e---->',e)
    errorMsgs = errorMsgs + str(e) +'\r\n'
try:       
    from pytz import timezone
except Exception as e:
    print('e---->',e)
    errorMsgs = errorMsgs + str(e) +'\r\n'

def get_pst_time():
    date_format=  '%Y-%m-%d_%H-%M-%S' #'%m-%d%Y_%H_%M_%S_%Z'
    date = datetime.now(tz=pytz.utc)
    date = date.astimezone(timezone('US/Pacific'))
    pstDateTime=date.strftime(date_format)
    return pstDateTime
#给param1，param2添加规则
def modification_rules(TestActions):
    dic = {'relaySwitch':{'param1':'netname','param2':'state'},'checkVBUS':{'param1':'netname','param2':'reference'},'readVoltage':{'param1':'netname','param2':'gain'},
    'parseLDCMString':{'param1':'pattern','param2':'pattern_limit'},'sendCmdAndParse':{'param1':'pattern','param2':'mark'},'sendCmdAndParseWithDC':{'param1':'pattern','param2':'attribute'},
    'parseWithRegexString':{'param1':'pattern','param2':'attribute'},'readAndCheckOTP':{'param1':'pattern','param2':'attribute'},'readGPIOState':{'param1':'netname','param2':'reference'},
    'checkScannedSNAndMLBSN':{'param1':'pattern','param2':'attribute'},'setAmplification':{'param1':'netname','param2':'netname2'},'orionTest':{'param1':'param1','param2':'param2'},
    'powerSupply':{'param1':'powertype','param2':'start'}}
    param1 = ''
    param2 = ''
    allkeys = dic.keys()
    if TestActions in allkeys:
        param1 = dic[TestActions]['param1']
        param2 = dic[TestActions]['param2']
    return param1,param2
#填充字典
def design_dic(Technology,TestName,subsubtestname,param1,param2,timeout,TestActions,description,fail_count,key,val,nyquist_group,nyquist_proposed_rate):
    dic_mas = {'unit':"",'low':"",'high':""}
    dic_mas['technology'] = Technology
    dic_mas['testname'] = TestName
    dic_mas['subsubtestname'] = subsubtestname
    dic_mas['timeout'] = timeout
    dic_mas['testactions'] = TestActions
    dic_mas['description'] = description
    dic_mas['fail_count'] = fail_count
    dic_mas['key'] = key
    dic_mas['val'] = val
    dic_mas['param1'] = param1
    dic_mas['param2'] = param2
    dic_mas['nyquist_group'] = nyquist_group
    dic_mas['nyquist_proposed_rate'] = nyquist_proposed_rate
    return dic_mas
#去掉'"',' ','}'
def remove_symbol(mas_param):
    while 1:
        if mas_param[:1] != '"' and mas_param[:1] != ' ':
             break
        mas_param = mas_param[1:]
    while 1:
        if mas_param[-1:] != '"' and mas_param[-1:] != '}':
            break
        mas_param = mas_param[:-1]
    return mas_param

def create_testplan(path):
    mas_all = []
    path_limit=path+'/Limits.csv'
    path_main=path+'/Main.csv'
    path_Sampling=path+'/Sampling.csv'
    # 打开Limits.csv，去掉表头
    with open(path_limit)as a:
        limit_list = list(csv.reader(a))
        limit_list.pop(0)
    # 打开Main.csv，去掉表头
    with open(path_main, 'r') as f:
        reader_main = list(csv.reader(f))
        reader_main.pop(0)
    # 打开Sampling.csv，去掉表头
    with open(path_Sampling, 'r') as f:
        reader_Sampling = list(csv.reader(f))
        reader_Sampling.pop(0)
    #根据Main.csv中的Technology来打开对应的csv文件
    for mas in reader_main:
        path_csv = path+'/Tech/' + mas[1] + '.csv'
        with open(path_csv, 'r') as f:
            reader_Tech = list(csv.reader(f))
            reader_Tech.pop(0)
        #一行行遍历csv的内容，并取得所需内容
        num_Tech = 0
        while num_Tech < len(reader_Tech):
            if reader_Tech[num_Tech][0] == '':
                reader_Tech[num_Tech][0] = reader_Tech[num_Tech-1][0]
            if reader_Tech[num_Tech][0] == mas[0]:
                fail_count = ''
                nyquist_group = ''
                nyquist_proposed_rate = ''

                nyquist_group = mas[8]
                if nyquist_group != '':
                    for x in reader_Sampling:
                        if nyquist_group == x[0]:
                            nyquist_proposed_rate = x[1]
                if mas[9] == 'Y':
                        fail_count = 1
                #去掉"subsubtestname","timeout","unit","record"
                mas_list_param1 = reader_Tech[num_Tech][7].split('",')
                num = 0
                a = len(mas_list_param1)
                while num < a:
                    if '"subsubtestname"' in mas_list_param1[num].lower() or '"timeout"' in mas_list_param1[num].lower() or '"unit"' in mas_list_param1[num].lower() or '"record"' in mas_list_param1[num].lower():
                        mas_list_param1.remove(mas_list_param1[num])
                        a -= 1
                        num -= 1
                    num += 1
                mas_list = re.findall(r'(?<=")(.*?)(?=")',reader_Tech[num_Tech][7])
                #AdditionalParameters为空的情况
                if len(mas_list)<1:
                    param1 = ''
                    param2 = ''
                    subsubtestname = ''
                    timeout = ''
                    key = ''
                    val = ''
                    TestActions = ''
                    
                    list_TestActions = reader_Tech[num_Tech][1].split(':')
                    if len(list_TestActions) > 1:
                        TestActions = list_TestActions[1]
                    else:
                        TestActions = reader_Tech[num_Tech][1]
                    if reader_Tech[num_Tech][5] != '':
                        timeout = reader_Tech[num_Tech][5]
                    if '==' in reader_Tech[num_Tech][12]:
                        conditon = reader_Tech[num_Tech][12].split('==')
                        key = "{{" + str(conditon[0]) + "}}"
                        val = conditon[1]
                    param2 = reader_Tech[num_Tech][10]
                    mas_all.append(design_dic(mas[1],mas[0],subsubtestname,param1,param2,timeout,TestActions,mas[11],fail_count,key,val,nyquist_group,nyquist_proposed_rate))
                num_list = 0
                while num_list < len(mas_list):
                    param1 = ''
                    param2 = ''
                    subsubtestname = ''
                    timeout = ''
                    key = ''
                    val = ''
                    TestActions = ''

                    list_TestActions = reader_Tech[num_Tech][1].split(':')
                    if len(list_TestActions) > 1:
                        TestActions = list_TestActions[1]
                    else:
                        TestActions = reader_Tech[num_Tech][1]
                    param1_rule,param2_rule = modification_rules(TestActions)
                    if len(param1_rule) > 0 or len(param2_rule) > 0:
                        for x in mas_list_param1:
                            if param1_rule in x:
                                param1 = x.split(':')[1]
                                param1 = remove_symbol(param1)
                            if param2_rule in x:
                                param2 = x.split(':')[1]
                                param2 = remove_symbol(param2)
                    else:
                        num_param = 0
                        while num_param < len(mas_list_param1):
                            mas_param = mas_list_param1[num_param].split('":')[1]
                            mas_param = remove_symbol(mas_param)
                            param1 = param1 + mas_param + ';'
                            num_param += 1
                        if param1 == ';':
                            param1 = ''
                        else:
                            param1 = param1[:-1]
                        param2 = reader_Tech[num_Tech][10]
                    if 'timeout' == mas_list[num_list].lower():
                        timeout = mas_list[num_list+2]
                    if reader_Tech[num_Tech][5] != '':
                        timeout = reader_Tech[num_Tech][5]
                    if '==' in reader_Tech[num_Tech][12]:
                        conditon = reader_Tech[num_Tech][12].split('==')
                        key = "{{" + str(conditon[0]) + "}}"
                        val = conditon[1]
                    if 'subsubtestname' == mas_list[num_list]:
                        subsubtestname = mas_list[num_list+2]
                        mas_all.append(design_dic(mas[1],mas[0],subsubtestname,param1,param2,timeout,TestActions,mas[11],fail_count,key,val,nyquist_group,nyquist_proposed_rate))
                    num_list += 1
            num_Tech += 1
    for i in mas_all:
        for x in limit_list:
            if i['testname']==x[0] and i['subsubtestname']==x[1]:
                i['unit']=x[2]
                i['high']=x[3]
                i['low']=x[4]
    # 制作最后要生成的testplan
    # 表头
    data=[['TESTNAME','SUBTESTNAME','SUBSUBTESTNAME','DESCRIPTION','FUNCTION','TIMEOUT','PARAM1','PARAM2','UNIT','LOW','HIGH','KEY','VAL','FAIL_COUNT','NYQUIST_GROUP','NYQUIST_PROPOSED_RATE']]
    for i in mas_all:
        if '@'in i['testname']:
            i['testname']=re.findall(r'.*?(?=@)',i['testname'])[0]
        elif '-'in i['testname']:
            i['testname']=re.findall(r'.*?(?=-)',i['testname'])[0]
        else:
            i['testname']=i['testname']
        my_list=[i['technology'],i['testname'],i['subsubtestname'],i['description'],i['testactions'],i['timeout'],i['param1'],i['param2'],i['unit'],i['low'],i['high'],i['key'],i['val'],i['fail_count'],i['nyquist_group'],i['nyquist_proposed_rate']]
        data.append(my_list)
    # with open ('./testplan.csv','w')as f:
    #     for x in data:
    #         csv.writer(f).writerow(x)
    return data

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
                            if '.csv' not in msg[2]:
                                data = create_testplan(msg[2])

                                cpklog = os.path.expanduser("~/Desktop/CPK_Log/")
                                if not os.path.exists(cpklog):
                                    os.makedirs(cpklog)

                                msg[2] = os.path.expanduser("~/Desktop/CPK_Log/")+ "LegacyTestPlan" + "__" + str(get_pst_time()) + ".csv"
                                print('2..........msg[2]',msg[2])
                                with open (msg[2],'w')as f:
                                    for x in data:
                                        csv.writer(f).writerow(x)

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



