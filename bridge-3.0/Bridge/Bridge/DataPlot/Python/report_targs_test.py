#! /usr/bin/env python3
# --*-- coding: utf-8 ---*---

import sys,os,time,math,re
import time
import threading
import datetime
from pytz import timezone
import pytz

from post import *

BASE_DIR=os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0,BASE_DIR+'/site-packages/')

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

print(sys.getdefaultencoding())

def send_progress_info(info,progress,title="Tags report"):
    import json
    filelogname = '/tmp/CPK_Log/temp/.keynote.txt'
    with open(filelogname, 'w') as file_object:
        dictInfo = {}
        dictInfo["info"] = info
        dictInfo["title"] = title
        dictInfo["progress"] = progress
        dictInfo["type"] = "-Progress-"



        file_object.write(json.dumps(dictInfo, indent=4))

redisClient = redis.Redis(host='localhost', port=6379, db=0)
context = zmq.Context()
socket = context.socket(zmq.REP)
socket.setsockopt(zmq.LINGER,0)
socket.bind("tcp://127.0.0.1:3190")

filelogname = '/tmp/CPK_Log/temp/.reporttags.txt'


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

def creat_excel_report_file(excel_file_path):

    book = xlsxwriter.Workbook(excel_file_path)
    report_sheet = book.add_worksheet('report')
    report_sheet.set_column("A:A", 15)
    report_sheet.set_column("B:B", 50)
    report_sheet.set_column("C:C", 50)
    report_sheet.set_row(0, 30)    #设置行高度
    format_normal = book.add_format()  # 定义format格式对象
    format_normal.set_align('center')  # 定义format_titile对象单元格对齐方式
    format_normal.set_valign('center') # 定义format_titile对象单元格对齐方式
    format_normal.set_border(1)  # 定义format对象单元格边框加粗的格式
    format_normal.set_text_wrap()  # 内容换行

    format_title = book.add_format()  # 定义format格式对象
    format_title.set_align('center')  # 定义format_titile对象单元格对齐方式
    format_title.set_valign('center') # 定义format_titile对象单元格对齐方式
    format_title.set_bg_color('#cddccc')  # 定义format_titile对象单元格背景颜色
    format_title.set_border(1)  # 定义format对象单元格边框加粗的格式
    # format_title.set_num_format('0.00')  # 格式化数据格式为小数点后两位
    format_title.set_text_wrap()  # 内容换行

    return book,report_sheet,format_normal,format_title

def open_all_csv_local(csv_path):
    tmp_lst = []
    with open(csv_path, 'r') as f:
        reader = csv.reader(f)
        for row in reader:
            tmp_lst.append(row)

    return tmp_lst


def generate_excel(table_data):



    create_report(event,header_list,df,color_by1,fail_pic_path,select_category_l1,cpk_lsl,cpk_usl,
                    cpk_path,set_bins,excel_report_file_name,project_code,build_stage,station_name,
                    start_time_first,start_time_last,color_by2,select_category_l2,excel_report_item,
                    fail_plot_to_excel,zoom_type,param_item_start_index)
    
    print('==[='+str(start_time)+' '+str(datetime.datetime.now())+']','create excel report finished!')

    with open(filelogname, 'w') as file_object:
        file_object.write("Finished," + excel_report_name)


def csv_to_xlsx_pd(table_data):
    global filelogname
    csv_source_path = table_data[0]
    output_excel_path = table_data[1]
    excel_report_name = table_data[2]

    PostProgressMsg(70,"csv_to_xlsx_pd ongoing","Tags report (python)")
    tab_data = open_all_csv_local(csv_source_path)
    book,report_sheet,format_normal,format_title = creat_excel_report_file(output_excel_path)
    j=1
    for column_data in tab_data:
        item_name=column_data
        location = 'A' + str(j)
        if j<3:
            report_sheet.write_row(location,item_name,format_title)
        else:
            report_sheet.write_row(location,item_name,format_normal)
        j=j+1
    book.close()

    PostProgressMsg(100,"csv_to_xlsx_pd finish","Tags report (python)")
    # csv = pd.read_csv(csv_source_path, encoding='utf-8')
    # csv.to_excel(output_excel_path, sheet_name='report')
    filelogname = '/tmp/CPK_Log/temp/.reporttags.txt'
    with open(filelogname, 'w') as file_object:
        file_object.write("Finished," + output_excel_path)

def run(n):
    while True:
        try:
            print("wait for report tages client ...")
            zmqMsg = socket.recv()
            socket.send(b'reporttags.csv')  # socket.send(ret.decode('utf-8').encode('ascii'))
            if len(zmqMsg)>0:
                key = zmqMsg.decode('utf-8')
                print("message from report tags client:", key)

                PostProgressMsg(10,"start tags report","Tags report (python)")


                #send_progress_info("report tags ...",20)

                if key == 'generate_report_tags':
                    table_data = get_redis_data(key)

                    PostProgressMsg(30,"get redis datas","Tags report (python)")
                    if len(table_data)>0:
                        csv_to_xlsx_pd(table_data)

                        for x in range(1,10):
                            PostProgressMsg(100 + 3 * x,"csv_to_xlsx_pd finished ","Tags report (python)")
                    else:
                        with open(filelogname, 'w') as file_object:
                            file_object.write("Finished,get redis error")
                        PostProgressMsg(100,"redis datas is none","Tags report (python)")
  
            else:
                time.sleep(0.05)

        except Exception as e:
            print('error excel:',e)
            with open(filelogname, 'w') as file_object:
                file_object.write("Finished,create excel report error: " + str(e))
            PostProgressMsg(100,"exception happend {}".format(e),"Tags report (python)")

if __name__ == '__main__':
    run(0)
    
    
