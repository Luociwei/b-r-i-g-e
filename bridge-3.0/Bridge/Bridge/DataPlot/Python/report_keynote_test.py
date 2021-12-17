#! /usr/bin/env python3
# --*-- coding: utf-8 ---*---

import sys,os,time,math,re
import time
import threading
import datetime
from pytz import timezone
import pytz

from post import *

from functools import reduce

BASE_DIR=os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0,BASE_DIR+'/site-packages/')


def send_progress_info(info,progress,title="Keynote report"):
    PostProgressMsg(progress,info,title)
    #import json
    #filelogname = '/tmp/CPK_Log/temp/.keynote.txt'
    #with open(filelogname, 'w') as file_object:
    #    dictInfo = {}
    #    dictInfo["info"] = info
    #    dictInfo["title"] = title
    #    dictInfo["progress"] = progress
    #    dictInfo["type"] = "-Progress-"
#
#
#
    #    file_object.write(json.dumps(dictInfo, indent=4))

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



current_dir = os.path.dirname(os.path.realpath(__file__))
keynote_lib_path = current_dir+'/python_keynote'

try:
    from python_keynote import generate_keynote
except Exception as e:
    print('import python keynote---->',e)


try:
    import zmq
except Exception as e:
    print('import zmq error:',e)

try:
    import redis
except Exception as e:
    print('import redis error:',e)

print(sys.getdefaultencoding())

redisClient = redis.Redis(host='localhost', port=6379, db=0)

context = zmq.Context()
socket = context.socket(zmq.REP)
socket.setsockopt(zmq.LINGER,0)
socket.bind("tcp://127.0.0.1:3140")


g_plot_type = ""
g_is_skipSummary = ""


g_total_data = ""
g_overall_rate = ""
g_is_nodata = False


g_BMCInfoFilter = {}

def correlation(message):
    print("this function is generate correlation plot......")
    val = r.get(message)
    # time.sleep(5)  #测试python 执行时间 5s
    if val:
        return val
    else:
        return b'None'
        

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


def read_csv_to_list(csv_path):
    tmp_lst = []
    with open(csv_path, 'r') as f:
        reader = csv.reader(f)
        for i,row in enumerate(reader):
            tmp_lst = tmp_lst + row
    return tmp_lst


def clear_files(path):
    for root, dirs, files in os.walk(path):
        for file in files:
            os.remove(path + '/' + file)


def valid_column(test_item_name, column_list):
    if test_item_name.lower().find('fixture vendor_id') == -1 and test_item_name.lower().find('unit number') == -1:
        pass
    else:
        return 'not_cpk state1'
    if len(column_list) < 3:  
        return "not_cpk state2"
    else:
        
        j = 0
        for i in range(2, len(column_list), 1):
            if is_number(column_list[i]):
                j = j + 1
                if j > 0 and len(set(column_list)) >= 1:  #
                    # print('need_cpk')
                    return "need_cpk"

        return "not_cpk state3"

def test_value_to_numeric(test_data_list):
    column_list = []
    i = 0
    for x in test_data_list:
        if (i ==0 and (x == 'NA' or x == '')) or (i ==1 and (x == 'NA' or x == '')):
            column_list.append(x)
        else:
            try:
              x = float(x)
              column_list.append(x)
            except Exception as e:
                pass
            # print('-------------------- it is not number --------------')
        i = i + 1
    return column_list


def is_empty_list(l):
    temp_l = []
    for value in l:
        if value != '':
            temp_l.append(value)
    n = len(temp_l)
    if n == 0:
        # print('it is empty list!')
        return True
    else:
        return False


def parse_all_csv(header_list, df, color_by1, selected_category1, event, color_by2, selected_category2,param_item_start_index):
    color_l = ['#0000FF', '#FF0000', '#008000', '#00FFFF', '#000000', '#8B008B', '#B8860B', '#FF6347', '#A9A9A9','#FFFF00', '#A52A2A', '#7FFF00', '#D2691E', '#6495ED', '#FF00FF']
    table_data = []  # [[]]
    table_category_data = []  # [[[]]]
    column_list = []
    n = 0
    no_valid_column_name_l = []
    for item_name in header_list:
        try:
            column_list = df[item_name].tolist()
        except Exception as e:
            if event == 'excel-report' and header_list.index(item_name) >= param_item_start_index:
                no_valid_column_name_l.append(item_name)
            print(item_name, 'is duplicate ? pls check!', e)
            continue
        # print('column_list--->',type(df[item_name]),column_list)

        need_cpk = valid_column(item_name, column_list)
        # print('need_cpk:---->',need_cpk)
        column_num_list = []
        if need_cpk == 'need_cpk':
            column_list = test_value_to_numeric(column_list)
            column_list.insert(0, item_name)  # item name
            usl = column_list[1]
            lsl = column_list[2]
            # print('color_by1:',color_by1)
            # 'Off'/'SerialNumber'/'Version'/'Station ID'/'Special Build Name'/'Product'/'StartTime'/'Special Build Description'
            if color_by1 == 'SerialNumber' or color_by1 == 'Version' or color_by1 == 'Station ID' or color_by1 == 'Special Build Name' or color_by1 == 'Product' or color_by1 == 'StartTime' or color_by1 == 'Special Build Description' or color_by1 == 'Fixture Channel ID' or color_by1 == 'Diags_Version':
                column_temp = []
                first_filter_category_data_len = 0
                second_filter_category_data_len = 0
                i = 0
                for x in selected_category1:
                    # print('x:',x,color_by2)
                    if color_by2 == 'SerialNumber' or color_by2 == 'Version' or color_by2 == 'Station ID' or color_by2 == 'Special Build Name' or color_by2 == 'Product' or color_by2 == 'StartTime' or color_by2 == 'Special Build Description' or color_by2 == 'Fixture Channel ID' or color_by2 == 'Diags_Version':

                        for xx in selected_category2:
                            if color_by2 == 'Fixture Channel ID':
                                # print('the same!',df.columns.values.tolist()[14])
                                index2 = df.columns.values.tolist()[14]
                            index2 = color_by2
                            one_category_list = df.loc[(df[color_by1] == x[0]) & (df[index2] == xx[0]), item_name].tolist()  #
                            if is_empty_list(one_category_list) != True:
                                # print('one category_data with second filter-->', len(one_category_list),one_category_list)
                                second_filter_category_data_len = second_filter_category_data_len + len(one_category_list)
                                one_category_list = test_value_to_numeric(one_category_list)
                                column_temp = column_temp + one_category_list
                                category_value = x[0] + '&' + xx[0]
                                one_category_list.insert(0, category_value)  # insert category
                                # print('i==>',i)
                                if i > 14:
                                    i = 0
                                one_category_list.insert(1, color_l[i])  # insert color
                                one_category_list.insert(2, item_name)  # item_name
                                if lsl != 'NA':
                                    lsl = float(lsl)
                                if usl != 'NA':
                                    usl = float(usl)

                                one_category_list.insert(3, usl)  # usl
                                one_category_list.insert(4, lsl)  # lsl
                                # print('one_category_list-->', one_category_list)
                                column_num_list.append(one_category_list)
                                i = i + 1

                    elif color_by2 == 'Off':

                        # print('color_by2= Off xxxxx:', x[0],x[1])
                        one_category_list = df.loc[df[color_by1] == x[0], item_name].tolist()  #
                        if is_empty_list(one_category_list) != True:
                            # print('one category_data with first filter-->', one_category_list)
                            first_filter_category_data_len = first_filter_category_data_len + len(one_category_list)
                            one_category_list = test_value_to_numeric(one_category_list)
                            column_temp = column_temp + one_category_list

                            one_category_list.insert(0, x[0])  # insert category
                            one_category_list.insert(1, x[1])  # insert color
                            one_category_list.insert(2, item_name)  # item_name
                            # if lsl != 'NA' or usl != 'NA':
                            #     usl = float(usl)
                            #     lsl = float(lsl)


                            if lsl != 'NA':
                                    lsl = float(lsl)
                            if usl != 'NA':
                                    usl = float(usl)

                            one_category_list.insert(3, usl)  # usl
                            one_category_list.insert(4, lsl)  # lsl
                            # print('one_category_list-->', one_category_list)
                            column_num_list.append(one_category_list)
                # print('one category_data total with first filter-->', first_filter_category_data_len)
                # print('one category_data total with second filter-->', second_filter_category_data_len)

                column_temp.insert(0, item_name)  # item_name
                # if lsl != 'NA' or usl != 'NA':
                #     usl = float(usl)
                #     lsl = float(lsl)
                if lsl != 'NA':
                    lsl = float(lsl)
                if usl != 'NA':
                    usl = float(usl)


                column_temp.insert(1, usl)  # usl
                column_temp.insert(2, lsl)  # lsl
                # print('column_temp-->', column_temp)
                table_data.append(column_temp)  # one column's all category data []
                # print('column_num_list-->', column_num_list)
                table_category_data.append(column_num_list)  # category [[],[],...]]
            elif color_by1 == 'Off':
                if event == 'excel-report' or event == 'keynote-report':
                    if header_list.index(item_name) >= param_item_start_index:
                        table_data.append(column_list)  # item_name,usl,lsl,data
                else:
                    table_data.append(column_list)  # item_name,usl,lsl,data
        else:
            if (event == 'excel-report' or event == 'keynote-report') and header_list.index(item_name) >= param_item_start_index:
                no_valid_column_name_l.append(item_name)
    if event == 'excel-report':
        pass
    else:
        no_valid_column_name_l = []
    # print('no_valid_column_name_l-->',no_valid_column_name_l)
    return table_data, table_category_data, no_valid_column_name_l  # [[[ ]]]



def get_coefficients(value_l):
    '''
    param value_l: need float list
    return: bc,p_val,a_Q,a_irr,three_σ_x100_divide_mean
    1σ＝690000／1000000 #fault rate
    2σ＝308000／1000000
    3σ＝66800／1000000
    4σ＝6210／1000000
    5σ＝230／1000000
    6σ＝3.4／1000000 
    7σ＝0／1000000
    '''
    if len(value_l) <= 3:
        return '','','','',''
    
    column_stdev = np.std(value_l,ddof=1,axis=0)
    three_sigma= 3*column_stdev
    # print('three_sigma:',column_stdev,three_sigma)
    temp_l= value_l
    if len(value_l) < 10:
        temp_l = value_l + value_l
        if len(temp_l)<10:
            temp_l = value_l + value_l + value_l + value_l+value_l + value_l + value_l + value_l+value_l + value_l

    # print('------>>>temp_l:',temp_l)
    data0 = np.array(temp_l)
    # print('------>>>data0:',data0)
    try:
        dip, p_val = diptest.diptest(data0)
        p_val = '%f'%p_val
        # print('------>>>p_val :',p_val)
    except RuntimeWarning as w:
        print('calculate dip,p_val RuntimeWarning:',w)
        return '','','','',''        
    except Exception as e:
        print('calculate dip,p_val error:',e)
        return '','','','',''
    # print('dip,p_val:',dip,p_val)
    item_name ='value1'
    data = pd.DataFrame({item_name:value_l})
    # print('data--->',type(data),data)
    u1 = data[item_name].mean() # 计算均值
    # std1 = data[item_name].std() # 计算标准差
    # t,pval=stats.kstest(data[item_name], 'norm', (u1, std1))
    # print('normality test t,pval:',str(t),str(pval))

    # print('------')
    # 正态性检验 → pvalue >0.05

    n= float(len(value_l))
    #Item (xi-ẍ)^2
    item_l_1 =[]
    item_l_2 = []
    item_l_3 = []
    for i in value_l:
        temp1 = (i-u1)**2
        temp2 = (i-u1)**3
        temp3 = (i-u1)**4
        item_l_1.append(temp1)
        item_l_2.append(temp2)
        item_l_3.append(temp3)
    sum_item_l_1 = sum(item_l_1)
    sum_item_l_2 = sum(item_l_2)
    sum_item_l_3 = sum(item_l_3)
    if n<=3 or sum_item_l_1==0 or sum_item_l_2==0 or sum_item_l_3==0:
        # print('len < 3--->')
        if abs(u1) == 0:
            return 'Nan',str(p_val),'Nan','Nan','Nan'
        else:
            three_CV = three_sigma*100/abs(u1)
            return 'Nan',str(p_val),'Nan','Nan',str(round(three_CV,6))
    else:
        try:
            m3 = np.sqrt(n*(n-1))/(n-2)*((1/n*sum_item_l_2)/np.sqrt(1/n*sum_item_l_1)**3)

            # print('m3=',m3)
            # print('d8:',n+1)
            # print('d15:',1/n*sum_item_l_3/(1/n*sum_item_l_1)**2)
            # print('d16:',(n+1)*1/n*sum_item_l_3/(1/n*sum_item_l_1)**2-3*(n-1))
            # print('d6/d7',(n-1)/((n-2)*(n-3)))
            m4 = ((n-1)/((n-2)*(n-3)))*((n+1)*1/n*sum_item_l_3/(1/n*sum_item_l_1)**2-3*(n-1))#(d6/d7)*d16
            # print('m4=',m4)
            #(d14**2+1)/(d17+3*(d10/d7))
            bc =(m3**2+1)/(m4+3*((n-1)**2/((n-2)*(n-3))))
            # print('bc:',bc)
            a_L=0.05
            a_M=0.1
            a_U=0.32
            a_Q = (a_U-a_L)*bc**2+a_L
            # print ('a_Q:',a_Q)
            a_irr = np.sqrt((a_U-a_L)**2*bc)+a_L
            # print('a_irr:',a_irr)
        except Exception as e:
            # print('calculate error',e)
            if abs(u1) == 0:
                return 'Nan',str(p_val),'Nan','Nan','Nan'
            else:
                three_CV = three_sigma*100/abs(u1)
                # print('three_CV:',three_CV)
                return 'Nan',str(p_val),'Nan','Nan',str(round(three_CV,6))


    if abs(u1) == 0:
        return str(round(bc,6)),str(p_val),str(round(a_Q,6)),str(round(a_irr,6)),'Nan'
    else:
        three_CV = three_sigma*100/abs(u1)
        # print('three_CV:',three_CV)
        return str(round(bc,6)),str(p_val),str(round(a_Q,6)),str(round(a_irr,6)),str(round(three_CV,6))


def cpk_calc(df_data,lsl,usl):
    """
    :param df_data: list
    :param usl: 数据指标上限
    :param lsl: 数据指标下限
    :return:
    """

    sigma = 3
    # print('limit--->',lsl,usl)
    # 数据平均值
    # print('df_data in cpk_calc:',df_data)
    mean = np.mean(df_data)#
    
    # print('mean ---->',mean)

    # 数据max值
    max_num = max(df_data)
    # print('max_num ---->',max_num)

    # 数据min值
    min_num = min(df_data)
    # print('min_num ---->',min_num)

    # a = np.array([[1, 2], [3, 4]])
    # print('a--->', type(a))
    # print('gobal std:',np.std(a))#全局标准差
    # print('each line std:',np.std(a, axis=0,ddof=1))
    # print("each row std:",np.std(a, axis=1,ddof=1))

    # 数据标准差
    if len(df_data)==1:
        stdev =0.00
        mean = round(mean,3)
        return (mean,max_num,min_num,stdev,None,None,None,None,None)
    else:
        try:
            stdev = np.std(df_data,ddof=1,axis=0)
        except Exception as e:
            mean = round(mean,3)
            return (mean,max_num,min_num,stdev,None,None,None,None,None)


    # print('stdev ---->',stdev)
    if stdev == 0:#stop count cpk
        mean = round(mean,3)
        return (mean,max_num,min_num,stdev,None,None,None,None,None)
    # 生成横轴数据平均分布
    # x1 = np.linspace(mean - sigma * stdev, mean + sigma * stdev, 1000)
    # print('x1 ---->',x1)
    # 计算正态分布曲线
    # y1 = np.exp(-(x1 - mean) ** 2 / (2 * stdev ** 2)) / (math.sqrt(2 * math.pi) * stdev)
    # print('y1 ---->',y1)
    x1,y1 = None,None

    if (lsl != 'NA' and  lsl != '') and (usl == 'NA' or usl == ''):
        cpl = (mean - lsl) / (sigma * stdev)
        # print('====>>>>>>cpl',cpl)
        mean = round(mean,3)
        return (mean,max_num,min_num,stdev,None,None,None,cpl,None)

    if (usl != 'NA' and usl != '') and (lsl == 'NA' or  lsl == ''):
        # print('====>>>>>>=====cpu')
        cpu = (usl - mean) / (sigma * stdev)
        # print('====>>>>>>cpu',cpu)
        mean = round(mean,3)
        return (mean,max_num,min_num,stdev,None,None,cpu,None,None)

    if lsl == 'NA' or usl == 'NA' or lsl == '' or usl == '':
        return (mean,max_num,min_num,stdev,None,None,None,None,None)
    cpu = (usl - mean) / (sigma * stdev)
    cpl = (mean - lsl) / (sigma * stdev)

    # 得出cpk
    cpk = min(cpu, cpl)
    mean = round(mean,3)
    return (mean,max_num,min_num,stdev,x1,y1,cpu,cpl,cpk)




def get_target_value(lsl, usl):
    if lsl != 'NA' and usl != 'NA' and lsl != '' and usl != '':
        target_value = round(((lsl + usl) / 2.0), 5)
    else:
        target_value = 'Nan'
    return target_value


def checkItemName(item_name,item_length):
    if len(item_name) > item_length:
        if item_name[item_length] == '_' or item_name[item_length] == ' ':
            item_name = item_name[0:item_length+1] + '\n' + item_name[item_length+1:]
        else:
            item_name1 = item_name[0:item_length]
            item_name_tmp = item_name1[::-1]
            x1=item_name_tmp.find('_')
            x2=item_name_tmp.find(' ')
            x_len = 0
            if x1 == -1 and x2 == -1:
                x_len = 0
            elif x1 == -1:
                x_len = x2
            elif x2 ==-1:
                x_len = x1
            elif x1>x2:
                x_len = x2
            else:
                x_len = x1
            x_len = len(item_name1) - x_len
            item_name = item_name[0:x_len] + '\n' + item_name[x_len:]
    return item_name


def probability_distribution_extend(data,bins,margin,item_name,lsl,usl,mean,max_num,min_num,
                                    stdev,x1,y1,cpu,cpl,cpk,pic_path,bins_l,bins_h,start_time_first,
                                    start_time_last,bmc,zoom_type='limit'):
    
    try:
        permin=round(np.percentile(data,2),3)
    except Exception as e:
        permin = ''
    try:
        permax=round(np.percentile(data,98),3)
    except Exception as e:
        permax = ''

    max_num_orig = max_num
    min_num_orig = min_num
    mean_orig = mean
    bins = sorted(bins)
    length = len(bins)
    intervals = np.zeros(length+1)
    for value in data:
        i = 0
        while i < length and value >= bins[i]:
            i += 1
        intervals[i] += 1
    intervals = intervals / float(len(data))
    plt.ion()  # 开启interactive mode

    plt.figure(1)  # 创建图表1
    plt.xlim(min(bins) - margin, max(bins) + margin)
    bins.insert(0, -999)
    # plt.title("probability-distribution",size=8,verticalalignment='bottom')
    plt.bar(bins, intervals,color=['r'], label='')#频率分布
    x_ticks,labels = plt.xticks()
    y_ticks, labels = plt.yticks()
    y_ticks=round(y_ticks[len(y_ticks) - 1],5)
    plt.close(1)

    plt.figure(2,dpi=150)  # 创建图表2
    fig, axes = plt.subplots(1, 0, figsize=(6, 5), facecolor='#ccddef')
    plt.axes([0.11, 0.17, 0.85, 0.7])  # [左, 下, 宽, 高] 规定的矩形区域 （全部是0~1之间的数，表示比例）

    if stdev =='nan':
        pass  
    else:
        if stdev > 999999:
            stdev = str("%.3e" % stdev)
        else:
            stdev = str("%.3f" % stdev)

    if cpl ==None:

        cpl_value =''
    else:
        if cpl > 999999:
            cpl_value = str("%.3e" % cpl)
        else:
            cpl_value = str("%.3f" % cpl)

    if cpu ==None:
        cpu_value =''
    else:
        if cpu > 999999:
            cpu_value = str("%.3e" % cpu)
        else:
            cpu_value = str("%.3f" % cpu)


    if cpk ==None:
        cpk_value =''
    else:
        if cpk > 999999:
            cpk_value = str("%.3e" % cpk)
        else:
            cpk_value = str("%.3f" % cpk)


    if max_num > 999999:
        max_num = str("%.6e" % max_num)
    else:
        max_num = str("%.3f" % max_num)

    if mean > 999999:
        mean = str("%.6e" % mean)
    else:
        mean = str("%.3f" % mean)

    if min_num > 999999:
        min_num = str("%.6e" % min_num)
    else:
        min_num = str("%.3f" % min_num)


    if len(data) > 1000000000000:
        sample_n = str("%.e" % len(data))
    else:
        sample_n = str("%.f" % len(data))

    info = "Samples:" + sample_n + '  ' +"Max:" + str(max_num_orig) + '  ' + "Min:" + str(min_num_orig) + '\n' + "Mean:" + str(mean_orig) + '  '+ "Std:" + stdev + '  ' + "Cpl:" + cpl_value + '  ' + "Cpu:" + cpu_value + '\n' + "Cpk:" + cpk_value  + '  ' + '02%:'+ str(permin) + '  ' + '98%:' + str(permax) + '  '+ "Bimodal:" + bmc
    item_name = checkItemName(str(item_name),55)
    plt.title(item_name,size=11,verticalalignment='bottom')
    plt.ylabel('Count')
    bins = [round(x,5) for x in bins]
    bins=sorted(bins)
    plt.hist(data, bins=bins, histtype='stepfilled',color = 'blue', edgecolor='blue', linewidth=1.0,align='mid',density=False) #time分布
    
    range_value = get_limit_range(bins_l, bins_h)
    range_value =round(range_value/5,5)

    if zoom_type =='data':
        range_offset = abs(float(max_num_orig) - float(min_num_orig))*0.2
        plt.xlim(float(min_num_orig)-float(range_offset), float(max_num_orig)+float(range_offset))

    else:
        if (lsl =='' or lsl =='NA') and (usl!='NA'and usl!=''):
            plt.xlim(float(min_num_orig)*0.999, usl+range_value)
        elif (usl =='' or usl =='NA') and (lsl!='NA'and lsl!=''):
            plt.xlim(lsl-range_value, float(max_num_orig)*1.001)
        elif (usl =='' or usl =='NA') and (lsl=='NA'or lsl==''):
            plt.xlim(float(min_num_orig)*0.999, float(max_num_orig)*1.001)
        else:
            plt.xlim(bins_l-range_value, bins_h+range_value)


    y_ticks = len(data) * y_ticks
    plt.ylim((0, y_ticks))  # 设置y轴scopex

    ax=plt.gca()
    ax.spines['bottom'].set_linewidth(1)
    ax.spines['left'].set_linewidth(1)
    ax.spines['right'].set_linewidth(1)
    ax.spines['top'].set_linewidth(1)


    if lsl !='' and lsl !='NA' and zoom_type =='limit':
        plt.plot([lsl, lsl, ], [0, y_ticks, ], 'k--', linewidth=1.0, color='red')  # 画lower limit线，
        plt.text(lsl, y_ticks / 3, ' LSL\n' + ' ' + str(lsl), fontdict={'size': 8, 'color': 'r'})

    if usl != '' and usl != 'NA' and zoom_type =='limit':
        plt.plot([usl, usl, ], [0, y_ticks, ], 'k--', linewidth=1.0, color='red')  # 画upper limit线，
        plt.text(usl, y_ticks / 2, ' USL\n' + ' ' + str(usl), fontdict={'size': 8, 'color': 'r'})
        
    plt.text(0.0,-0.236, info,fontsize=10,ha="left",transform=ax.transAxes)
    plt.legend(bbox_to_anchor=(0.9,-0.09),loc="best",fontsize=10,framealpha=0,edgecolor='royalblue',borderaxespad=0.1)
    plt.grid(linestyle=':',c='gray')  # 生成网格
    plt.savefig(pic_path,dpi=200)
    plt.draw()
    plt.close('all')
    plt.ioff()  


def get_bins(min_num, max_num, lsl, usl, set_bins, zoom_type):
    bins_l = 0
    bins_h = 0
    if lsl == 'NA' or usl == 'NA' or zoom_type == 'data':
        bins_l, bins_h = min_num, max_num
    else:
        if min_num < lsl and max_num < lsl:
            bins_l = min_num
            bins_h = usl
        elif min_num < lsl and max_num > lsl and max_num <= usl:
            bins_l = min_num
            bins_h = usl
        elif min_num < lsl and max_num > usl:
            bins_l = min_num
            bins_h = max_num
        elif lsl <= min_num and min_num <= usl and max_num <= usl:
            bins_l = lsl
            bins_h = usl
        elif lsl <= min_num and min_num <= usl and max_num > usl:
            bins_l = lsl
            bins_h = max_num
        elif min_num > usl:
            bins_l = lsl
            bins_h = max_num
    range_value = get_limit_range(bins_l, bins_h)
    if lsl == 'NA' or usl == 'NA' or zoom_type == 'data':
        if range_value == 0 and min_num > 0:
            range_value = min_num * 0.2
            bins_l = (bins_l - min_num * 0.1)
            bins_h = (bins_h + min_num * 0.1)

        elif range_value == 0 and min_num == 0:
            range_value = 6
            bins_l = - 3
            bins_h = 3
        elif range_value == 0 and min_num < 0:
            range_value = 6
            bins_l = min_num - 3
            bins_h = min_num + 3
 
        else:
            if min_num > 1 and range_value < 1 and range_value != 0:
                range_value = min_num * 0.05
                bins_l = (bins_l - min_num * 0.025)
                bins_h = (bins_h + min_num * 0.025)
            elif min_num > 0.001 and min_num < 1 and range_value < 1 and range_value != 0:
                range_value = min_num * 0.2
                bins_l = (bins_l - min_num * 0.1)
                bins_h = (bins_h + min_num * 0.1)

            else:
                range_value = range_value * 0.4
                bins_l = (bins_l - range_value * 0.2)
                bins_h = (bins_h + range_value * 0.2)


    else:
        if range_value == 0 and lsl != 0:
            range_value = lsl * 0.2
            bins_l = bins_l - lsl * 0.1
            bins_h = bins_h + usl * 0.1
        elif range_value == 0 and lsl == 0:
            range_value = 6
            bins_l = - 3
            bins_h = 3

    range_value = round((range_value / set_bins), 12)
    # print('range_value2-->',range_value)
    # print('=====>',bins_l,bins_h,range_value)
    # bins = np.arange(bins_l, bins_h, range_value)  # 必须是单调递增的
    bins = np.arange(bins_l, bins_h, range_value)#必须是单调递增的
    if bins_l<0:
        bins = np.arange(bins_h, bins_l, -range_value)
    # print('lsl,usl,min_num,max_num,bins_l,bins_h in get_bins=====>',lsl,usl,min_num,max_num,bins_l,bins_h)
    return bins, bins_l, bins_h


def get_limit_range(lsl, usl):
    # print('lsl,usl----->', lsl, usl)
    range_value = 0
    if lsl < 0 and usl <= 0:
        range_value = abs(lsl) - abs(usl)
    elif lsl < 0 and usl >= 0:
        range_value = abs(lsl) + usl
    elif lsl >= 0 and (usl > 0):
        range_value = usl - lsl
    else:
        print('get_limit_range 00000')
    range_value = round(range_value, 5)
    return range_value


def probability_distribution_extend_by_color(column_category_data_list, data, bins, margin, item_name, lsl, usl, mean,
                                             max_num, min_num, stdev, x1, y1, cpu, cpl, cpk, pic_path, bins_l, bins_h,
                                             start_time_first, start_time_last, bmc, zoom_type):
    # print('one column data len:',len(data),item_name,data,column_category_data_list)
    
    try:
        permin=round(np.percentile(data,2),3)
    except Exception as e:
        permin = ''
    try:
        permax=round(np.percentile(data,98),3)
    except Exception as e:
        permax = ''
    max_num_orig = max_num
    min_num_orig = min_num
    mean_orig = mean
    bins = sorted(bins)
    length = len(bins)
    intervals = np.zeros(length + 1)
    for value in data:
        i = 0
        while i < length and value >= bins[i]:
            i += 1
        intervals[i] += 1
    intervals = intervals / float(len(data))
    plt.ion()  # 开启interactive mode

    plt.figure(1)  # 创建图表1
    plt.xlim(min(bins) - margin, max(bins) + margin)
    bins.insert(0, -999)
    plt.title("probability-distribution")
    plt.bar(bins, intervals, color=['r'], label='')  # 频率分布
    x_ticks, labels = plt.xticks()
    x_ticks_start = round(x_ticks[0], 2)
    x_ticks_end = round(x_ticks[len(x_ticks) - 1], 2)
    y_ticks, labels = plt.yticks()
    # print('y_ticks--->',y_ticks,y_ticks[len(y_ticks) - 1],y_ticks[0])
    y_ticks = round(y_ticks[len(y_ticks) - 1], 5)
    # print("x_ticks_start,x_ticks_end--->",x_ticks_start,x_ticks_end)
    # print('y_ticks_end--->',y_ticks)
    # plt.show()
    plt.close(1)

    plt.figure(2, dpi=150)  # 创建图表2,facecolor='blue',edgecolor='black'

    if stdev == 'nan':
        pass
    else:
        if stdev > 999999:
            stdev = str("%.3e" % stdev)
        else:
            stdev = str("%.3f" % stdev)

    if cpl == None:
        cpl_value = ''
    else:
        if cpl > 999999:
            cpl_value = str("%.3e" % cpl)
        else:
            cpl_value = str("%.3f" % cpl)

    if cpu == None:
        cpu_value = ''
    else:
        if cpu > 999999:
            cpu_value = str("%.3e" % cpu)
        else:
            cpu_value = str("%.3f" % cpu)

    if cpk == None:
        cpk_value = ''
    else:
        if cpk > 999999:
            cpk_value = str("%.3e" % cpk)
        else:
            cpk_value = str("%.3f" % cpk)

    if max_num > 999999:
        max_num = str("%.3e" % max_num)
    else:
        max_num = str("%.3f" % max_num)

    if mean > 999999:
        mean = str("%.3e" % mean)
    else:
        mean = str("%.3f" % mean)

    if min_num > 999999:
        min_num = str("%.3e" % min_num)
    else:
        min_num = str("%.3f" % min_num)

    if len(data) > 1000000000000:
        sample_n = str("%.e" % len(data))
    else:
        sample_n = str("%.f" % len(data))

    info = "Samples:" + sample_n + '  ' +"Max:" + str(max_num_orig) + '  ' + "Min:" + str(min_num_orig) + '\n' + "Mean:" + str(mean_orig) + '  '+ "Std:" + stdev + '  ' + "Cpl:" + cpl_value + '  ' + "Cpu:" + cpu_value + '\n' + "Cpk:" + cpk_value  + '  ' + '02%:'+ str(permin) + '  ' + '98%:' + str(permax) + '  '+ "Bimodal:" + bmc

    item_name = checkItemName(str(item_name),55)
    # if len(item_name) > 55:
    #     item_name = item_name[0:55] + '\n' + item_name[55:]
    # font = FontProperties(fname=r"/Library/Fonts/Songti.ttc", size=12)
    plt.title(item_name, size=10)
    plt.xlabel(str(start_time_first) + ' -- ' + str(start_time_last))
    plt.ylabel('Count')

    # plt.title(item_name+"\nCpk={0}".format(str("%.6f" % cpk)))
    # plt.hist(x=data, bins=bins, density=False, histtype='bar', color=['r'])
    bins = [round(x, 5) for x in bins]
    bins = sorted(bins)
    l = 0
    l_len = []
    for category_data in column_category_data_list:
        # print('category_test_data--->', category_data[5:])
        # print('category_name,category_color--->', category_data[0],str(category_data[1]))
        category_name, category_color = category_data[0], str(category_data[1])
        n = len(category_data[5:])
        l = l + n
        # print('category len:',n)
        l_len.append(n)
        if len(column_category_data_list) == 1:
            plt.hist(category_data[5:], bins=bins, label=category_data[0], color=category_color, histtype='stepfilled',
                     edgecolor=category_color, linewidth=1.5, align='mid', density=False)  # time分布
        else:
            plt.hist(category_data[5:], bins=bins, label=category_data[0], color='white', histtype='step',
                     edgecolor=category_color, linewidth=1.5, align='mid', density=False)  # time分布
    # print('----->a column len,max in one category:-->',l,max(l_len))


    y_ticks = max(l_len) * (y_ticks + 0.04)
    range_value = get_limit_range(bins_l, bins_h)
    range_value = round(range_value / 5, 5)
    # print('plot bar--->',bins_l,range)
    plt.xlim(bins_l - range_value, bins_h + range_value)
    plt.ylim((0, y_ticks))  # 设置y轴scopex

    ax = plt.gca()
    ax.spines['bottom'].set_linewidth(1.5)
    ax.spines['left'].set_linewidth(1.5)
    ax.spines['right'].set_linewidth(1.5)
    ax.spines['top'].set_linewidth(1.5)

    # plt.plot(x1, y1, 'k--', label="", linewidth=1.0, color='lime')  # 画正态分布曲线
    if lsl != 'NA' and usl != 'NA' and zoom_type == 'limit':
        plt.plot([lsl, lsl, ], [0, y_ticks, ], 'k--', linewidth=3.0, color='red')  # 画lower limit线，
        plt.plot([usl, usl, ], [0, y_ticks, ], 'k--', linewidth=3.0, color='red')  # 画upper limit线，
        # 添加文字
        # plt.text(0.1,20, r'$\mu=100,\ \sigma=15$')
        plt.text(lsl, y_ticks / 3, ' LSL\n' + ' ' + str(lsl), fontdict={'size': 10, 'color': 'r'})
        plt.text(usl, y_ticks / 2, ' USL\n' + ' ' + str(usl), fontdict={'size': 10, 'color': 'r'})
        # plt.axis([-0.2, 0.2,0, 100])#x 轴，y 轴

    plt.text(bins_l + range_value / 3, y_ticks * 0.78, info, size=10, rotation=0.0, alpha=0.85, fontsize=8, ha="left",
             va="center", bbox=dict(boxstyle="round", ec=('royalblue'), linestyle='-.', lw=1, fc=('white'), ))

    # os.system('mkdir fail')
    if len(column_category_data_list) < 30:
        plt.legend(loc="upper right", framealpha=1, edgecolor='royalblue', borderaxespad=0.3,
                   fontsize=6)  # facecolor ='None',

    # plt.legend(bbox_to_anchor=(1.01, 1), loc=2, borderaxespad=0)
    plt.grid(linestyle=':', c='gray')  # 生成网格
    # path="/Users/rex/PycharmProjects/my/fail/"
    plt.savefig(pic_path, dpi=200)
    plt.draw()
    # plt.show()
    plt.close('all')

    plt.ioff()




def verify_limit(lsl, usl):
    if lsl != None:
        lsl.replace(' ', '')
    if usl != None:
        usl.replace(' ', '')
    try:
        lsl = float(eval(lsl))
    except:
        lsl = None
    try:
        usl = float(eval(usl))
    except:
        usl = None
    return lsl, usl



def draw_histogram(column_data, item_name, lsl, usl, mean, max_num, min_num, stdev, x1, y1, cpu, cpl, cpk, pic_path,
                   set_bins, start_time_first, start_time_last, bmc, zoom_type):
    bins, bins_l, bins_h = get_bins(min_num, max_num, lsl, usl, set_bins, zoom_type)
    # print(len(column_data),'-==--->',min(column_data),max(column_data),bins)
    probability_distribution_extend(column_data, bins, 0, item_name, lsl, usl, mean, max_num, min_num, stdev, x1, y1,
                                    cpu, cpl, cpk, pic_path, bins_l, bins_h, start_time_first, start_time_last,bmc,
                                    zoom_type)

    return True


def draw_more_histogram(column_category_data_list, column_data, item_name, lsl, usl, mean, max_num, min_num, stdev, x1,
                        y1, cpu, cpl, cpk, pic_path, set_bins, start_time_first, start_time_last, bmc,zoom_type):
    """

    """
    # print('9999 column_category_data_list--->',column_category_data_list)
    # print('9999 column_data--->',len(column_data),column_data)

    # range = get_limit_range(lsl, usl)
    # range = round((range /set_bins), 5)
    # bins = np.arange(lsl, usl, range)  # 必须是单调递增的
    bins, bins_l, bins_h = get_bins(min_num, max_num, lsl, usl, set_bins, zoom_type)
    probability_distribution_extend_by_color(column_category_data_list, column_data, bins, 0, item_name, lsl, usl, mean,
                                             max_num, min_num, stdev, x1, y1, cpu, cpl, cpk, pic_path, bins_l, bins_h,
                                             start_time_first, start_time_last, bmc,zoom_type)

    return True


def get_project_info(data_df):
    project_code = get_project_code(data_df)
    # print('--------------------project_code:'+project_code+'------------------------')

    build_stage = get_build_stage(data_df)
    # print('--------------------build_stage:'+build_stage+'-------------------------')

    station_name = get_station_name(data_df)
    # print('--------------------station_name:'+station_name+'------------------------')
    return project_code, build_stage, station_name


def get_build_stage(data_df):
    special_build_name = data_df['Special Build Name'].values.tolist()  # Special Build Name
    # pattern =re.compile(r'.*\-(.+)\-')
    # result=pattern.match(build_stage)
    # build_stage = result.group(1)
    build_stage = ''
    build_stage_l = list(set(special_build_name))

    temp_l = []
    for i in build_stage_l:
        pattern = re.compile(r'.*\-(.+)')
        result = pattern.match(i)
        if result:
            temp_l.append(result.group(1))
        else:
            temp_l.append(i)
    n = 1
    for j in list(set(temp_l)):
        if n == 1:
            build_stage = j
        else:
            build_stage = build_stage + '&' + j
        n = n + 1
    return build_stage


def get_station_name(data_df):
    # station_name = data_df[1:2].values[0].tolist()[6] #Station ID first cell
    station_name_l = data_df['Station ID'].values.tolist()  # Station ID first cell
    station_name_l = list(set(station_name_l))
    station_name = ''
    if len(station_name_l) == 0:
        print('data is empty!')
        station_name == 'xxx'
    else:
        for i in station_name_l:
            if i != '':
                pattern = re.compile(r'.*\_([0-9]+)\_(\D+)')
                result = pattern.match(i)
                try:
                    station_name = result.group(2)
                    return station_name
                except Exception as e:
                    print('match station_name error')

    return station_name


def get_project_code(data_df):
    product_l = list(set(data_df['Product'].values.tolist()))  # Product first cell
    # print("=============>>>>>>product_l", product_l)
    project_code = ''
    n = 1
    for i in product_l:
        if n == 1:
            project_code = i
        else:
            project_code = project_code + '&' + i
        n = n + 1

    return project_code


def open_all_csv(event, all_csv_path, data_select, remove_fail):
    tmp_lst = []
    print('>-all_csv_path:',all_csv_path)
    with open(all_csv_path, 'r') as f:
        reader = csv.reader(f)
        i = 1
        for row in reader:
            if row[0].lower().find('display name') != -1:
                pass
            elif row[0].lower().find('pdca priority') != -1:
                pass
            elif row[0].lower().find('upper limit') != -1:
                tmp_lst.append(row)
            elif row[0].lower().find('lower limit') != -1:
                tmp_lst.append(row)
            elif row[0].lower().find('measurement unit') != -1:  # "Measurement Unit ----->" in row:
                pass
            elif row[0].lower().find('site') != -1:
                tmp_lst.append(row)
            else:
                tmp_lst.append(row)
            i = i + 1

    param_item_start_index = tmp_lst[0].index('Parametric')
    header_list = tmp_lst[1]

    df = pd.DataFrame(tmp_lst[2:], columns=tmp_lst[1])
    header_df = df[0:2]
    data_df = df[2:]
    # data_df = data_df[~data_df['SerialNumber'].isin([''])]  # Remove SN Empty
   

    if remove_fail == 'yes':
        data_df = data_df[data_df['Test Pass/Fail Status'].isin(['PASS'])]
        # data_df=data_df[~data_df['Test Pass/Fail Status'].isin(['FAIL'])]

    # if data_select == 'first':
    #     data_df = data_df.sort_values(axis=0, by=['StartTime'], ascending='True')
    #     data_df.drop_duplicates(['SerialNumber'], keep='first', inplace=True)
    # elif data_select == 'last':
    #     data_df = data_df.sort_values(axis=0, by=['StartTime'], ascending='True')
    #     data_df.drop_duplicates(['SerialNumber'], keep='last', inplace=True)
    # elif data_select == 'no_retest':
    #     data_df.drop_duplicates(['SerialNumber'], keep=False, inplace=True)
    # elif data_select == 'all':
    #     pass
    # print('csv data row number after remove retest--->', len(data_df.values.tolist()))
    # if event == 'keynote-report' or event == 'excel-report':
    #     try:
    #         project_code, build_stage, station_name = get_project_info(data_df)
    #     except Exception as e:
    #         print('get project code,stage,station name:',e)
    #         project_code, build_stage, station_name = '', '', ''
        
    # else:
    
    project_code, build_stage, station_name = '', '', ''

    # start_time_l  = data_df['StartTime'].values.tolist() #StartTime
    # if len(start_time_l)>0:
    #     start_time_first = min(start_time_l)
    #     start_time_last  = max(start_time_l)
    # else:
    #     start_time_first = ''
    #     start_time_last  = ''
    # print('<first time -- last time>',start_time_first,start_time_last)

    start_time_first = ''
    start_time_last  = ''

    df = header_df.append(data_df)
    return header_list, df, project_code, build_stage, station_name, start_time_first, start_time_last, param_item_start_index

def get_file_pic_name(file_dir):
    pic_file_l = []
    files = os.listdir(file_dir)
    files.sort(key=lambda x: str(x.split('.')[0]))
    for file in files:
        if os.path.splitext(file)[1] == '.png':
            pic_file_l.append(os.path.splitext(file)[0])
    return pic_file_l


def get_file_pic_table(file_dir):

    file_name_table = []
    pic_file_name = []
    name_tag_table = []
    files = os.listdir(file_dir)
    if '.DS_Store' in files:
        files.remove('.DS_Store')
    files.sort(key=lambda x: str(x.split('.')[0]))
    ii = 0
    count_files = len(files)

    for file in files:
        if os.path.splitext(file)[1] == '.png':
            list_file_name = os.path.splitext(file)[0]
            tmp = list_file_name.split(' ')

            name_tag = ''
            if len(tmp) >2:
                if '@' in tmp[1]:
                    tmp_coverage = tmp[1].split('@')
                    name_tag = tmp[0]+ ' '+tmp_coverage[0]
                elif '-' in tmp[1]:
                    tmp_coverage = tmp[1].split('-')
                    name_tag = tmp[0]+ ' '+tmp_coverage[0]
                else:
                    name_tag = tmp[0]+ ' '+tmp[1]
            else:
                name_tag = list_file_name

            # print('name_tag',name_tag)

            if name_tag not in name_tag_table:
                if ii != 0:
                    file_name_table.append(pic_file_name)
                pic_file_name = []
                
            pic_file_name.append(list_file_name)
            name_tag_table.append(name_tag)

            if count_files == ii+1:
                file_name_table.append(pic_file_name)

            ii = ii+1
                
    return file_name_table


def get_pst_time():
    date_format=  '%Y-%m-%d_%H-%M-%S' #'%m-%d%Y_%H_%M_%S_%Z'
    date = datetime.datetime.now(tz=pytz.utc)
    date = date.astimezone(timezone('US/Pacific'))
    pstDateTime=date.strftime(date_format)
    return pstDateTime

def topersent(inputs):
    return list(map(lambda x:list(map(lambda y:y*0.01,x)),inputs)) 

def summary_retest(csv_pah):
    df = pd.read_csv(csv_pah)
    categories = ["Date","ALL","ALL_#TOTAL","ALL_#RATE","OVERALL_RETEST_RATE_#RATE"]
    strRowName = list(df[categories[0]])


    strHeaders = ["ALL:({}/{})".format(sum(list(df["ALL"])),sum(list(df["ALL_#TOTAL"]))),"OVERALL_RETEST_RATE({}%)".format(list(df["OVERALL_RETEST_RATE_#RATE"])[0])]
    

    

    global g_overall_rate 
    g_overall_rate = strHeaders[1]

    strDatas = [list(df[categories[3]]),list(df[categories[4]])]
    return  strHeaders,strRowName,strDatas

def top10_retest1(csv_pah):
    print("In read CSV !!! {}".format(csv_pah))
    df = pd.read_csv(csv_pah)

    df = df.drop(index=[0])


    keys = list(df.columns.values)



    print("In read CSV !!! {}".format(keys))

    def splitstring(intput,size):
        if len(intput) > size:
            line = ""
            i = 0
            for x in intput:
                line = line + x
                i = i+1
                if i >= size:
                    line = line + "\n"
                    i = 0
            return line
        else:
            return intput




    #strRowName = list(map(lambda x:re.sub("\\s+","\n",x),list(df[keys[0]])))

    strRowName = list(map(lambda x:splitstring(x,15),list(df[keys[0]])))

    strHeaders = ["Total Input Count({})".format(keys[1])]

    global g_total_data

    g_total_data = strHeaders[0]

    datalist = list(map(lambda x:int(x),list(df[keys[1]]))) 
    #dataRate = list(map(lambda n: reduce(lambda x, y: int(x)+int(y), datalist[:n])/ sum(datalist),range(1,len(datalist)+1)))

    strDatas = [datalist]
    print("fail strHeaders:{},strRowName:{},strDatas:{}".format(strHeaders,strRowName,strDatas))
    return  strHeaders,strRowName,strDatas



def version_fail_retest(csv_pah):
    print("In read CSV !!! {}".format(csv_pah))
    df = pd.read_csv(csv_pah)

    df = df.sort_values(['RATE'],ascending=(False))

    keys = list(df.columns.values)

    print("In read CSV !!! {}".format(keys))

    categories = list(filter(lambda x:("RATE" in x),keys))
    strRowName = list(df["Index"])
    strHeaders = [g_total_data,g_overall_rate ]
    strDatas = list(map(lambda x:list(df[x]),categories))
    print("fail strHeaders:{},strRowName:{},strDatas:{}".format(strHeaders,strRowName,strDatas))
    return  strHeaders,strRowName,strDatas
def daily_fail_retest(csv_pah):

    print("In read CSV !!! {}".format(csv_pah))
    df = pd.read_csv(csv_pah)
    keys = list(df.columns.values)

    print("In read CSV !!! {}".format(keys))

    categories = list(filter(lambda x:("RATE" in x),keys))
    strRowName = list(df["Index"])
    strHeaders = [g_total_data,g_overall_rate ]
    strDatas = list(map(lambda x:list(df[x]),categories))
    print("fail strHeaders:{},strRowName:{},strDatas:{}".format(strHeaders,strRowName,strDatas))
    return  strHeaders,strRowName,strDatas


def fail_retest(csv_pah):
    df = pd.read_csv(csv_pah)
    keys = list(df.columns.values)

    #a.replace("_#Rate","")
    all_total = sum(list(df["ALL_#TOTAL"]))

    categories = list(filter(lambda x:("#RATE" in x and "OVERALL" not in x),keys))
    
    strRowName = list(df["Date"])
    strHeaders = categories
    #all_total

    strHeaders = list(map(lambda x:"{}:({}/{})".format(x.replace("_#RATE",""),sum(list(df[x.replace("_#RATE","")])),all_total),categories))

    strHeaders.append("OVERALL_RETEST_RATE({}%)".format(list(df["OVERALL_RETEST_RATE_#RATE"])[0]))
    #
    #strHeaders = ["ALL({}/{})".format(sum(list(df["ALL"])),sum(list(df["ALL_#TOTAL"]))),"OVERALL_RETEST_RATE({}%)".format(list(df["OVERALL_RETEST_RATE_#RATE"])[0])]
    strDatas = list(map(lambda x:list(df[x]),categories))
    strDatas.append(list(df["OVERALL_RETEST_RATE_#RATE"]))

    print("fail strHeaders:{},strRowName:{},strDatas:{}".format(strHeaders,strRowName,strDatas))
    return  strHeaders,strRowName,strDatas

def yield_donut(csv_pah):
    df = pd.read_csv(csv_pah)
    categories = ['1st PASS','Retest PASS','FAILED','PASSED','No Retest PASS','TOTAL']  #1st PASS,Retest PASS,FAILED,PASSED,No Retest PASS,TOTAL
    the_first_pass_count = max(df[categories[0]])
    the_second_pass_count = max(df[categories[1]])
    fail_count = max(df[categories[2]])
    total_count = max(df[categories[5]])

    global g_is_nodata
    g_is_nodata = True if int(total_count) == 0 else False

    if g_is_nodata:
        return None,None,None

    first_pass_rate = float(the_first_pass_count)/float(total_count)
    send_pass_rate = float(the_second_pass_count)/float(total_count)
    fail_rate = float(fail_count)/float(total_count)

    strHeaders = ["{}:{}/{}".format(categories[0],the_first_pass_count,total_count),"{}:{}/{}".format(categories[1],the_second_pass_count,total_count),"{}:{}/{}".format(categories[2],fail_count,total_count)]
    

    strRowName = ["row"]
    strDatas = [[the_first_pass_count,the_second_pass_count,fail_count]]
    return  strHeaders,strRowName,strDatas

def generate_keynote_report(project_code,station_name,build_stage,dir_path,project_name,target_build,plot_count_in_slide):

    #send_progress_info("Keynote Report generating ....",50)
    try:
        keynote_title_name = str(project_name)+'-'+str(target_build)+'-'+station_name+'\nData Analysis' 
        description_info =  'Issue description:\n'
        root_cause_info = 'Root Cause:\n'
        plan_info = 'Next steps:'
    
        if not os.path.exists(dir_path):
            os.makedirs(dir_path)
    
        keynote_save_path = dir_path+str(project_name)+'_'+str(target_build)+'_Data_Review_'+str(get_pst_time())+'.key'
        with open('/tmp/CPK_Log/temp/.keynotereportname.txt', 'w') as file_object:
            file_object.write(keynote_save_path)
    
        PostProgressMsg(100,"prepare folder for report finish ... start launch keynote .... ","Keynote report (python)")
    
        for x in range(1,10):
            PostProgressMsg(100 + x * 3,"prepare folder for report finish ... start launch keynote .... ","Keynote report (python)")
    
        doc,keynote = generate_keynote.create_keynote(keynote_title_name)
        print('save title page to keynote report finished!')
    
        print("Start call keynot job :{}".format(keynote))
    
        if g_plot_type == "keynote":
    
            if not g_is_skipSummary:
                generate_keynote.add_build_summary_overview(doc,keynote,'/tmp/CPK_Log/temp/yield_rate_param.csv','/tmp/CPK_Log/retest/retest_pie.png')
                print('add_build_summary_overview finished')
                header,rownames,datas =  yield_donut("/tmp/CPK_Log/retest/.pie_retest.csv")
        
                #global g_is_nodata
        
                if not g_is_nodata:
                    print(header,rownames,datas)
                    generate_keynote.add_build_yield_pie_keynote(doc,keynote,header,rownames,datas)
                    print('add_build_yield_pie finished')
            
                    is_no_retest = False
                
                    header,rownames,datas =  top10_retest1("/tmp/CPK_Log/retest/retest_item_overall.csv")
                    if len(rownames) >0 :
                        generate_keynote.build_failures_retest_top10_keynote(doc,keynote,header,rownames,datas,0,"Retest Pareto Chart")
                    else:
                        is_no_retest = True
                    
                    if not is_no_retest:
                        header,rownames,datas =  top10_retest1("/tmp/CPK_Log/retest/fail_item_overall.csv")
                        if len(rownames) >0 :
                            generate_keynote.build_failures_retest_top10_keynote(doc,keynote,header,rownames,datas,1,"Fail Pareto Chart")
                
                        #Daily Retest Summary Chart All Product Wise
                        header,rownames,datas =  summary_retest("/tmp/CPK_Log/retest/.summary_retest.csv")
                        generate_keynote.build_failures_retest_pareto1_keynote(doc,keynote,header,rownames,datas,"Daily Retest Summary Chart All Product Wise")
                        
                
                        #Daily Retest Summary Chart All Product Wise
                        header,rownames,datas =  fail_retest("/tmp/CPK_Log/retest/.summary_retest.csv")
                        if len(rownames) >0 :
                            generate_keynote.build_failures_retest_pareto1_keynote(doc,keynote,header,rownames,datas,"Daily Retest Summary Chart Product Wise")
                        
                
                
                        #Daily Retest Summary Chart Product Wise
                        header,rownames,datas =  daily_fail_retest('/tmp/CPK_Log/retest/.retest_vs_station_id.csv')
                        if len(rownames) >0 :
                            generate_keynote.build_summary_all_retest_rates_keynote(doc,keynote,header,rownames,datas,"Retest rate vs Station ID & Slot ID")
                        print('build_summary_all_retest_rates finished')
                
                        #Retest rate vs Station ID & Slot ID
                        header,rownames,datas =  version_fail_retest('/tmp/CPK_Log/retest/.retest_vs_version.csv')
                        if len(rownames) >0 :
                            generate_keynote.build_summary_retest_rates_keynote(doc,keynote,header,rownames,datas,"Retest rate vs SW version")
                        print('build_summary_retest_rates finished')
            else:
                print('Data is None !!!')
    
            
        elif "numbers" in g_plot_type:
            if not g_is_skipSummary:
                generate_keynote.add_build_summary_overview(doc,keynote,'/tmp/CPK_Log/temp/yield_rate_param.csv','/tmp/CPK_Log/retest/retest_pie.png')
                print('add_build_summary_overview finished')
                header,rownames,datas =  yield_donut("/tmp/CPK_Log/retest/.pie_retest.csv")
                if not g_is_nodata:
        
                    print(header,rownames,datas)
                    generate_keynote.add_build_yield_pie_keynote(doc,keynote,header,rownames,datas)
                    print('add_build_yield_pie finished')
            
            
                    is_no_retest = False
                
                    header,rownames,datas =  top10_retest1("/tmp/CPK_Log/retest/retest_item_overall.csv")
                    #datas = topersent(datas)
                    if len(rownames) >0 :
                        generate_keynote.build_failures_retest_top10_keynote_numbers(doc,keynote,header,rownames,datas,0,"Retest Pareto Chart")
                    else:
                        is_no_retest = True
        
                    if not is_no_retest:
                    
                        header,rownames,datas =  top10_retest1("/tmp/CPK_Log/retest/fail_item_overall.csv")
                        #datas = topersent(datas)
                        if len(rownames) >0 :
                            generate_keynote.build_failures_retest_top10_keynote_numbers(doc,keynote,header,rownames,datas,1,"Fail Pareto Chart")
                
                        
                        
                        #Daily Retest Summary Chart All Product Wise
                        header,rownames,datas =  summary_retest("/tmp/CPK_Log/retest/.summary_retest.csv")
                        datas = topersent(datas)
                
                        print("before build number =====>> {} {}".format(rownames,header))
                        if len(rownames) >0 :
                            generate_keynote.build_failures_retest_pareto1_keynote_numbers(doc,keynote,header,rownames,datas,"Daily Retest Summary Chart All Product Wise")
                        
                
                        #Daily Retest Summary Chart All Product Wise
                        header,rownames,datas =  fail_retest("/tmp/CPK_Log/retest/.summary_retest.csv")
                        datas = topersent(datas)
                        if len(rownames) >0 :
                            generate_keynote.build_failures_retest_pareto1_keynote_numbers(doc,keynote,header,rownames,datas,"Daily Retest Summary Chart Product Wise")
                        
                
                
                        #Daily Retest Summary Chart Product Wise
                        header,rownames,datas =  daily_fail_retest('/tmp/CPK_Log/retest/.retest_vs_station_id.csv')
                        datas = topersent(datas)
                        if len(rownames) >0 :
                            generate_keynote.build_summary_all_retest_rates_keynote_numbers(doc,keynote,header,rownames,datas,"Retest rate vs Station ID & Slot ID")
                        print('build_summary_all_retest_rates finished')
                
                        #Retest rate vs Station ID & Slot ID
                        header,rownames,datas =  version_fail_retest('/tmp/CPK_Log/retest/.retest_vs_version.csv')
                        datas = topersent(datas)
                        generate_keynote.build_summary_retest_rates_keynote_numbers(doc,keynote,header,rownames,datas,"Retest rate vs SW version")
                        print('build_summary_retest_rates finished')
                else:
                    print('Data is None !!!')
        else:
            if not g_is_skipSummary:
        
                generate_keynote.add_build_summary_overview(doc,keynote,'/tmp/CPK_Log/temp/yield_rate_param.csv','/tmp/CPK_Log/retest/retest_pie.png')
                print('add_build_summary_overview finished')
                generate_keynote.add_build_yield_pie(doc,keynote,'/tmp/CPK_Log/retest/retest_pie.png')
                print('add_build_yield_pie finished')
                generate_keynote.build_failures_retest_pareto(doc,keynote,'/tmp/CPK_Log/retest/retest_pareto.png','/tmp/CPK_Log/retest/fail_pareto.png')
                print('build_failures_retest_pareto finished')
                generate_keynote.build_summary_all_retest_rates(doc,keynote,'/tmp/CPK_Log/retest/daily_all_retest_summary.png')
                print('build_summary_all_retest_rates finished')    
                generate_keynote.build_summary_retest_rates(doc,keynote,'/tmp/CPK_Log/retest/daily_retest_summary.png','/tmp/CPK_Log/retest/retest_vs_station_id.png','/tmp/CPK_Log/retest/retest_vs_version.png')
                print('build_summary_retest_rates finished')
    
        if not g_is_skipSummary:
            generate_keynote.top_5_fail_and_retest(doc,keynote,'/tmp/CPK_Log/retest/fail_item_overall.csv','/tmp/CPK_Log/retest/retest_item_overall.csv')
            print('top_5_fail_and_retest finished')
            generate_keynote.fixture_retest_breakdown(doc,keynote,'/tmp/CPK_Log/retest/retest_breakdown_fixture.csv')
            print('fixture_retest_breakdown finished')
            generate_keynote.max_min_cpk_technology(doc,keynote,'/tmp/CPK_Log/retest/cpk_min_max.csv')
            print('max_min_cpk_technology finished')
            generate_keynote.create_abnormal_distribution(doc,keynote,'Abnormal Distribution\nAnalysis')
    
        fail_pic_path = '/tmp/CPK_Log/fail_plot'
        
        if int(plot_count_in_slide) == 1:
            file_l=[]
            file_l = get_file_pic_name(fail_pic_path)
            print('one slider add 1 pic')
            for f_name in file_l:
                one_fail_pic_path = fail_pic_path +'/'+f_name+'.png'

                scv_path =  "/tmp/CPK_Log/temp/{}.csv".format(f_name)
                generate_keynote.add_fail_pic(doc,keynote,one_fail_pic_path,f_name,description_info,root_cause_info,plan_info,g_BMCInfoFilter[f_name],scv_path)

        else:
            print('one slider add pic count:',plot_count_in_slide)
            file_table = get_file_pic_table(fail_pic_path)
            generate_keynote.add_fail_multi_pic_in_one_slide(doc,keynote,fail_pic_path,file_table,int(plot_count_in_slide))
        #send_progress_info("finish Keynote report generate....",100)
    
        generate_keynote.save_keynote(doc,keynote,keynote_save_path)
        print('save fail_plot to keynote report finished!')
        
        if "numbers" in g_plot_type:
            generate_keynote.CloseNumbers(keynote)
    except Exception as e:
        generate_keynote.CloseNumbers(keynote)
        generate_keynote.CloseKeynotes(keynote)
        print('Exception in !'+ "generate_keynote_report")

        strErr = ""
        if "keynote" in  str(e) :
            strErr = "Bridge not enabled in Accessibility settings"
        PostJsonInfo( "exception^&^" +  strErr + "\n" + str(e) + "\n [generate_keynote_report]")
    

    


def create_keynote_report_all(event,header_list,df,color_by1,pic_path,select_category1,cpk_lsl,cpk_usl,
                                save_all_cpk_path,set_bins,excel_name,project_code,build_stage,station_name,
                                start_time_first,start_time_last,color_by2,select_category_l2,excel_report_item,
                                fail_plot_to_excel,zoom_type,param_item_start_index,project_name,target_build,plot_count_in_slider):
    clear_files('/tmp/CPK_Log/fail_plot/')

    try:
        table_data,table_category_data,no_valid_column_name_l = parse_all_csv(header_list,df,color_by1,select_category1,event,color_by2,select_category_l2,param_item_start_index)#
        i,j,n,t=0,0,0,0
        path=save_all_cpk_path
        result='pass'
        picFail_path = '/tmp/CPK_Log/fail_plot/'
        for column_data in table_data:
            # print('column_data length,column_data--->',t,len(column_data),column_data)
            item_name=column_data[0]
            if str(item_name).lower() != 'fixture channel id_' and str(item_name).lower() != 'head id':
                usl = column_data[1]
                lsl = column_data[2]
                column_data = column_data[3:]
    
                if len(column_data) >0:   
                    bc,p_val,a_Q,a_irr,three_CV = get_coefficients(column_data)
                    BMC = ''
                    if bc != '' and bc != 'Nan' and p_val != '' and a_Q != '' and p_val != 'Nan' and a_Q != 'Nan':
                        if float(p_val) <= float(a_Q) and float(bc)>0.555:
                            BMC = 'YES'
                        elif float(p_val) <= float(a_Q) and float(bc)<0.555:
                            BMC = 'YES'
                        elif float(p_val) > float(a_Q) and float(bc)>0.555:
                            BMC = 'YES'
                        elif float(p_val) > float(a_Q) and float(bc)<0.555 and (float(bc)-float(p_val))>=-0.1:
                            BMC = 'YES'
                        elif float(p_val) > float(a_Q) and float(bc)<0.555 and (float(bc)-float(p_val))<-0.1:
                            BMC = 'NO'
                        else:
                            BMC = ''
                    else:
                        BMC = ''                
    
                    row_data = []
                    target_value = 9999999999
                    mean, max_num, min_num, stdev, x1, y1, cpu, cpl, cpk = cpk_calc(column_data, lsl, usl)
                    if cpk:
                        pass
                        #Added By Vito
                        #if is_number(str(cpk)):
                        #    if float(cpk)>float(cpk_usl):
                        #        BMC = ''
    
                    result=''
                    if not os.path.exists(picFail_path):
                        os.makedirs(picFail_path)
                    image_name = item_name.replace('/','_')+".png"
                    pic_path = picFail_path + image_name
                    if len(table_category_data) == 0:
                        draw_histogram(column_data,item_name,lsl, usl, mean, max_num, min_num, 
                                        stdev, x1, y1, cpu, cpl, cpk, pic_path,set_bins,start_time_first,
                                        start_time_last,BMC,zoom_type)
                    else:
                        draw_more_histogram(table_category_data[t],column_data,item_name,lsl, usl, mean, 
                                            max_num, min_num, stdev, x1, y1, cpu, cpl, cpk, pic_path,
                                            set_bins,start_time_first,start_time_last,BMC,zoom_type)
    
                    j=j+1
                else:
                    pass 
            t = t + 1
        PostProgressMsg(80,"Parse csv data finish ...","Keynote report (python)")
    
        print('All items cpk calulate/draw plots/excel report finished!')
        generate_keynote_report(project_code,station_name,build_stage,save_all_cpk_path,project_name,target_build,plot_count_in_slider)


    except Exception as e:
        strErr = ""
        if "keynote" in  str(e) :
            strErr = "Bridge not enabled in Accessibility settings"
        PostJsonInfo( "exception^&^" +  strErr + "\n" + str(e) + "\n [create_keynote_report_all]")
    

    



def create_keynote_report_by_cpk(event,header_list,df,color_by1,pic_path,select_category1,cpk_lsl,cpk_usl,
                                save_all_cpk_path,set_bins,excel_name,project_code,build_stage,station_name,
                                start_time_first,start_time_last,color_by2,select_category_l2,excel_report_item,
                                fail_plot_to_excel,zoom_type,param_item_start_index,check_cpk_thhld,k_item_list,
                                project_name,target_build,plot_count_in_slider):
    clear_files('/tmp/CPK_Log/fail_plot/')
    
    table_data,table_category_data,no_valid_column_name_l = parse_all_csv(header_list,df,color_by1,select_category1,event,color_by2,select_category_l2,param_item_start_index)#
    i,j,n,t=0,0,0,0
    path=save_all_cpk_path
    picFail_path = '/tmp/CPK_Log/fail_plot/'
    result='pass'
    for column_data in table_data:

        item_name=column_data[0]
        if str(item_name).lower() != 'fixture channel id_' and str(item_name).lower() != 'head id':
            usl = column_data[1]
            lsl = column_data[2]
            column_data = column_data[3:]
            if len(column_data) >0:   
                bc,p_val,a_Q,a_irr,three_CV = get_coefficients(column_data)

                BMC = ''
                if bc != '' and bc != 'Nan' and p_val != '' and a_Q != '' and p_val != 'Nan' and a_Q != 'Nan':
                    if float(p_val) <= float(a_Q) and float(bc)>0.555:
                        BMC = 'YES'
                    elif float(p_val) <= float(a_Q) and float(bc)<0.555:
                        BMC = 'YES'
                    elif float(p_val) > float(a_Q) and float(bc)>0.555:
                        BMC = 'YES'
                    elif float(p_val) > float(a_Q) and float(bc)<0.555 and (float(bc)-float(p_val))>=-0.1:
                        BMC = 'YES'
                    elif float(p_val) > float(a_Q) and float(bc)<0.555 and (float(bc)-float(p_val))<-0.1:
                        BMC = 'NO'
                    else:
                        BMC = ''
                else:
                    BMC = ''

                row_data = []
                target_value = 9999999999
                mean, max_num, min_num, stdev, x1, y1, cpu, cpl, cpk = cpk_calc(column_data, lsl, usl)
                if cpk:
                    pass
                    #if is_number(str(cpk)):
                    #    if float(cpk)>float(cpk_usl):
                    #        BMC = ''

                if cpk !=None:
                    ui_select_item = ''
                    if item_name in k_item_list:
                        ui_select_item = 'yes'
                    if cpk < cpk_lsl or ui_select_item == 'yes':
                        result='FAIL'
                        if not os.path.exists(picFail_path):
                            os.makedirs(picFail_path)
                        image_name = item_name.replace('/','_')+".png"
                        pic_path = picFail_path + image_name
                        if len(table_category_data) == 0:
                            draw_histogram(column_data,item_name,lsl, usl, mean, max_num, min_num, stdev, x1, y1, cpu, cpl, cpk, pic_path,set_bins,start_time_first,start_time_last,BMC,zoom_type)
                        else:
                            draw_more_histogram(table_category_data[t],column_data,item_name,lsl, usl, mean, max_num, min_num, stdev, x1, y1, cpu, cpl, cpk, pic_path,set_bins,start_time_first,start_time_last,BMC,zoom_type)

                        j=j+1
                    elif cpk > cpk_lsl and cpk < cpk_usl and BMC == "YES" and check_cpk_thhld == 'yes':
                        result='FAIL'
                        if not os.path.exists(picFail_path):
                            os.makedirs(picFail_path)
                        image_name = item_name.replace('/','_')+".png"
                        pic_path = picFail_path + image_name
                        if len(table_category_data) == 0:
                            draw_histogram(column_data,item_name,lsl, usl, mean, max_num, min_num, stdev, x1, y1, cpu, cpl, cpk, pic_path,set_bins,start_time_first,start_time_last,BMC,zoom_type)
                        else:

                            draw_more_histogram(table_category_data[t],column_data,item_name,lsl, usl, mean, max_num, min_num, stdev, x1, y1, cpu, cpl, cpk, pic_path,set_bins,start_time_first,start_time_last,BMC,zoom_type)

                        j=j+1
                    elif cpk > cpk_lsl and BMC=="YES" and check_cpk_thhld == 'no':
                        result='FAIL'
                        if not os.path.exists(picFail_path):
                            os.makedirs(picFail_path)
                        image_name = item_name.replace('/','_')+".png"
                        pic_path = picFail_path + image_name
                        if len(table_category_data) == 0:
                            draw_histogram(column_data,item_name,lsl, usl, mean, max_num, min_num, stdev, x1, y1, cpu, cpl, cpk, pic_path,set_bins,start_time_first,start_time_last,BMC,zoom_type)
                        else:
                            draw_more_histogram(table_category_data[t],column_data,item_name,lsl, usl, mean, max_num, min_num, stdev, x1, y1, cpu, cpl, cpk, pic_path,set_bins,start_time_first,start_time_last,BMC,zoom_type)

                        j=j+1
            else:
                pass     
        t = t + 1

    PostProgressMsg(80,"Parse csv data finish ...","Keynote report (python)")
    print('All items cpk calulate/draw plots/excel report finished!')
    generate_keynote_report(project_code,station_name,build_stage,save_all_cpk_path,project_name,target_build,plot_count_in_slider)




def create_keynote_report_by_p_val(event,header_list,df,color_by1,pic_path,select_category1,cpk_lsl,cpk_usl,
                                    save_all_cpk_path,set_bins,excel_name,project_code,build_stage,station_name,
                                    start_time_first,start_time_last,color_by2,select_category_l2,excel_report_item,
                                    fail_plot_to_excel,zoom_type,param_item_start_index,check_cpk_thhld,k_item_list,
                                    project_name,target_build,plot_count_in_slider):
    clear_files('/tmp/CPK_Log/fail_plot/')
    table_data,table_category_data,no_valid_column_name_l = parse_all_csv(header_list,df,color_by1,select_category1,
                                                                            event,color_by2,select_category_l2,
                                                                            param_item_start_index)
    i,j,n,t=0,0,0,0
    picFail_path = '/tmp/CPK_Log/fail_plot/'
    path=save_all_cpk_path
    result='pass'
    
    for column_data in table_data:
        item_name=column_data[0]
        if str(item_name).lower() != 'fixture channel id_' and str(item_name).lower() != 'head id':
            usl = column_data[1]
            lsl = column_data[2]
            column_data = column_data[3:]
            if len(column_data) >0:   
                bc,p_val,a_Q,a_irr,three_CV = get_coefficients(column_data)

                BMC = ''
                if bc != '' and bc != 'Nan' and p_val != '' and a_Q != '' and p_val != 'Nan' and a_Q != 'Nan':
                    if float(p_val) <= float(a_Q) and float(bc)>0.555:
                        BMC = 'YES'
                    elif float(p_val) <= float(a_Q) and float(bc)<0.555:
                        BMC = 'YES'
                    elif float(p_val) > float(a_Q) and float(bc)>0.555:
                        BMC = 'YES'
                    elif float(p_val) > float(a_Q) and float(bc)<0.555 and (float(bc)-float(p_val))>=-0.1:
                        BMC = 'YES'
                    elif float(p_val) > float(a_Q) and float(bc)<0.555 and (float(bc)-float(p_val))<-0.1:
                        BMC = 'NO'
                    else:
                        BMC = ''
                else:
                    BMC = ''


                row_data = []
                target_value = 9999999999
                mean, max_num, min_num, stdev, x1, y1, cpu, cpl, cpk = cpk_calc(column_data, lsl, usl)
                
                if cpk:
                    pass
                    #if is_number(str(cpk)):
                    #    if float(cpk)>float(cpk_usl):
                    #        BMC = ''


                if check_cpk_thhld == 'yes':
                    if cpk !=None:
                        ui_select_item = ''
                        if item_name in k_item_list:
                            ui_select_item = 'yes'

                        if cpk < cpk_usl and BMC =="YES" or ui_select_item == 'yes':
                            result='FAIL'
                            if not os.path.exists(picFail_path):
                                os.makedirs(picFail_path)
                            image_name = item_name.replace('/','_')+".png"
                            pic_path = picFail_path + image_name
                            if len(table_category_data) == 0:
                                draw_histogram(column_data,item_name,lsl, usl, mean, max_num, 
                                                min_num, stdev, x1, y1, cpu, cpl, cpk, pic_path,
                                                set_bins,start_time_first,start_time_last,BMC,zoom_type)
                            else:
                                draw_more_histogram(table_category_data[t],column_data,item_name,lsl, 
                                                    usl, mean, max_num, min_num, stdev, x1, y1, cpu, 
                                                    cpl, cpk, pic_path,set_bins,start_time_first,start_time_last,
                                                    BMC,zoom_type)

                            j=j+1
                elif check_cpk_thhld == 'no':
                    ui_select_item = ''
                    if item_name in k_item_list:
                        ui_select_item = 'yes'
                    if BMC == 'YES' or ui_select_item == 'yes':
                        result='FAIL'
                        if not os.path.exists(picFail_path):
                            os.makedirs(picFail_path)
                        image_name = item_name.replace('/','_')+".png"
                        pic_path = picFail_path + image_name
                        if len(table_category_data) == 0:
                            draw_histogram(column_data,item_name,lsl, usl, mean, max_num, 
                                            min_num, stdev, x1, y1, cpu, cpl, cpk, pic_path,
                                            set_bins,start_time_first,start_time_last,BMC,zoom_type)
                        else:
                            draw_more_histogram(table_category_data[t],column_data,
                                                item_name,lsl, usl, mean, max_num, 
                                                min_num, stdev, x1, y1, cpu, cpl, cpk, 
                                                pic_path,set_bins,start_time_first,start_time_last,BMC,zoom_type)

                        j=j+1
            else:
                pass    
        t = t + 1

    PostProgressMsg(80,"Parse csv data finish ...","Keynote report (python)")

    print('All items cpk calulate/draw plots/excel report finished!')
    generate_keynote_report(project_code,station_name,build_stage,save_all_cpk_path,project_name,target_build,plot_count_in_slider,plot_count_in_slider)



def generate_report_for_keynote_1a_yes(table_data):

    try:
        cpk_lsl = table_data[0]  # cpk lsl
        cpk_usl = table_data[1] #float("inf")   #table_data[1]  # cpk usl
        cpk_path = table_data[2]  #'[NSString stringWithFormat:@"%@/CPK_Log/",desktopPath];
        filelogname = '/tmp/CPK_Log/temp/.keynote.txt'   #
    
        set_bins = table_data[3]  #250
        all_csv_path = table_data[4] #'csv 读取的数据路径，从此路径获得数据
    
        project_name = table_data[5]
        target_build = table_data[6]
        plot_count_in_slider = table_data[7]  # slider放几张图片 1，2，4，6，8
    
        global g_plot_type
        g_plot_type = table_data[8] # plot type : "python" / "keynote"
    
        global g_is_skipSummary
        g_is_skipSummary =True if table_data[9].lower() == "yes" else False
    
        print("Set plot_type {} {}".format(table_data[8],g_plot_type))
    
        event = 'keynote-report'
    
        color_by1 = 'Off'
        select_category_l1 =[]
    
        color_by2 = 'Off'
        select_category_l2 = []
    
        remove_fail = 'yes'
        data_select = 'all'
    
        fail_pic_path ='/tmp/CPK_Log/fail_plot/'
        excel_report_item = 'all'  #fail   all
        fail_plot_to_excel = 'no'  # yes   no
    
        zoom_type = 'limit'
    
        header_list,df,project_code,build_stage,station_name,start_time_first,start_time_last,param_item_start_index = open_all_csv(event,all_csv_path,data_select,remove_fail)
    
        excel_report_file_name = ''
    
        PostProgressMsg(40,"open csv data finish ...","Keynote report (python)")
        create_keynote_report_all(event,header_list,df,color_by1,fail_pic_path,select_category_l1,cpk_lsl,cpk_usl,cpk_path,
                                    set_bins,excel_report_file_name,project_code,build_stage,station_name,start_time_first,
                                    start_time_last,color_by2,select_category_l2,excel_report_item,fail_plot_to_excel,zoom_type,
                                    param_item_start_index,project_name,target_build,plot_count_in_slider)
    
        print('create keynote report finished!')
        with open(filelogname, 'w') as file_object:
            file_object.write("Finished,create keynote report finished")
    except Exception as e:
      
        strErr = ""
        if "keynote" in  str(e) :
            strErr = "Bridge not enabled in Accessibility settings"
        PostJsonInfo( "exception^&^" +  strErr + "\n" + str(e) + "\n [generate_report_for_keynote_1a_yes]")
    

    

    

def generate_report_for_keynote_1b_yes(table_data):
    try:
        cpk_lsl = table_data[0]  # cpk lsl
        cpk_usl = table_data[1] #float("inf")   #table_data[1]  # cpk usl
        cpk_path = table_data[2]  # [NSString stringWithFormat:@"%@/CPK_Log/",desktopPath];
        filelogname = '/tmp/CPK_Log/temp/.keynote.txt' 
    
        set_bins = table_data[3]  #250
        all_csv_path = table_data[4] #'csv 读取的数据路径，从此路径获得数据
        csv_select_k_path = table_data[5] #'界面上UI K 列选择的item csv
        
        check_cpk_thhld =  table_data[6]  # yes/no
        check_one_limit =  table_data[7]  # yes/no
    
        project_name = table_data[8]
        target_build = table_data[9]
        plot_count_in_slider = table_data[10]
    
        global g_plot_type
    
        g_plot_type = table_data[11] # plot type : "python" / "keynote"
        global g_is_skipSummary
        g_is_skipSummary =True if table_data[12].lower() == "yes" else False
        print("Set plot_type {} {}".format(table_data[11],g_plot_type))
        csv_select_k_path = os.path.join(csv_select_k_path+ '')
        k_item_list = read_csv_to_list(csv_select_k_path)
        event = 'keynote-report'
    
        color_by1 = 'Off'
        select_category_l1 =[]
    
        color_by2 = 'Off'
        select_category_l2 = []
    
        remove_fail = 'yes'
        data_select = 'all'
    
        fail_pic_path ='/tmp/CPK_Log/fail_plot/'
    
        excel_report_item = 'all'  #fail   all
        fail_plot_to_excel = 'no'  # yes   no
    
        zoom_type = 'limit'
    
        header_list,df,project_code,build_stage,station_name,start_time_first,start_time_last,param_item_start_index =  open_all_csv(event,all_csv_path,data_select,remove_fail)
    
        excel_report_file_name = ''
        PostProgressMsg(40,"open csv data finish ...","Keynote report (python)")
        create_keynote_report_by_cpk(event,header_list,df,color_by1,fail_pic_path,select_category_l1,cpk_lsl,cpk_usl,
                                    cpk_path,set_bins,excel_report_file_name,project_code,build_stage,
                                    station_name,start_time_first,start_time_last,color_by2,select_category_l2,
                                    excel_report_item,fail_plot_to_excel,zoom_type,param_item_start_index,check_cpk_thhld,
                                    k_item_list,project_name,target_build,plot_count_in_slider)
        print('create keynote report finished!')
        with open(filelogname, 'w') as file_object:
            file_object.write("Finished,create keynote report finished")
    except Exception as e:
        strErr = ""
        if "keynote" in  str(e) :
            strErr = "Bridge not enabled in Accessibility settings"
        PostJsonInfo( "exception^&^" +  strErr + "\n" + str(e) + "\n [generate_report_for_keynote_1b_yes]")
    






def generate_report_for_keynote_1b_no(table_data):
    try:
        cpk_lsl = table_data[0]  # cpk lsl
        cpk_usl = table_data[1]  # cpk usl
        cpk_path = table_data[2]  #'[NSString stringWithFormat:@"%@/CPK_Log/",desktopPath];
        filelogname = '/tmp/CPK_Log/temp/.keynote.txt'   
    
        set_bins = table_data[3]  #250
        all_csv_path = table_data[4] #'csv 读取的数据路径，从此路径获得数据
        csv_select_k_path = table_data[5] #'界面上UI K 列选择的item csv
    
        csv_select_k_path = os.path.join(csv_select_k_path+ '')
        k_item_list = read_csv_to_list(csv_select_k_path)
    
        check_cpk_thhld =  table_data[6]  # yes/no
        check_one_limit =  table_data[7]  # yes/no
    
        project_name = table_data[8]
        target_build = table_data[9]
        plot_count_in_slider = table_data[10]
    
        global g_plot_type
    
        g_plot_type = table_data[11] # plot type : "python" / "keynote"
    
        global g_is_skipSummary
        g_is_skipSummary =True if table_data[12].lower() == "yes" else False
        print("Set plot_type {} {}".format(table_data[8],g_plot_type))
    
        event = 'keynote-report'
        color_by1 = 'Off'
        select_category_l1 =[]
    
        color_by2 = 'Off'
        select_category_l2 = []
    
        remove_fail = 'yes'
        data_select = 'all'
    
        fail_pic_path ='/tmp/CPK_Log/fail_plot/'
    
        excel_report_item = 'all'  #fail   all
        fail_plot_to_excel = 'no'  # yes   no
    
        zoom_type = 'limit'
        header_list,df,project_code,build_stage,station_name,start_time_first,start_time_last,param_item_start_index =  open_all_csv(event,all_csv_path,data_select,remove_fail)
    
        excel_report_file_name = ''
        PostProgressMsg(40,"open csv data finish ...","Keynote report (python)")
        create_keynote_report_by_p_val(event,header_list,df,color_by1,fail_pic_path,select_category_l1,cpk_lsl,cpk_usl,cpk_path,set_bins,excel_report_file_name,project_code,build_stage,station_name,start_time_first,start_time_last,color_by2,select_category_l2,excel_report_item,fail_plot_to_excel,zoom_type,param_item_start_index,check_cpk_thhld,k_item_list,project_name,target_build,plot_count_in_slider)
        print('create keynote report finished!')
        with open(filelogname, 'w') as file_object:
            file_object.write("Finished,create keynote report finished")
    except Exception as e:
        strErr = ""
        if "keynote" in  str(e) :
            strErr = "Bridge not enabled in Accessibility settings"
        PostJsonInfo( "exception^&^" +  strErr + "\n" + str(e) + "\n [generate_report_for_keynote_1b_no]")
    

    
def calulateBM(column_data):
    bc,p_val,a_Q,a_irr,three_CV = get_coefficients(column_data)

    BMC = ''
    if bc != '' and bc != 'Nan' and p_val != '' and a_Q != '' and p_val != 'Nan' and a_Q != 'Nan':
        if float(p_val) <= float(a_Q) and float(bc)>0.555:
            BMC = 'YES'
        elif float(p_val) <= float(a_Q) and float(bc)<0.555:
            BMC = 'YES'
        elif float(p_val) > float(a_Q) and float(bc)>0.555:
            BMC = 'YES'
        elif float(p_val) > float(a_Q) and float(bc)<0.555 and (float(bc)-float(p_val))>=-0.1:
            BMC = 'YES'
        elif float(p_val) > float(a_Q) and float(bc)<0.555 and (float(bc)-float(p_val))<-0.1:
            BMC = 'NO'
        else:
            BMC = ''
    else:
        BMC = ''
    return BMC




def run(n):
    while True:
        try:
            print("wait for keynote client ...")
            zmqMsg = socket.recv()
            socket.send(b'keynote.key')  # socket.send(ret.decode('utf-8').encode('ascii'))
            if len(zmqMsg)>0:
                key = zmqMsg.decode('utf-8')
                print("message from keynote =====>>>>>>>>  client:", key)
                if key == 'generate_keynote_1a_yes':
                    PostProgressMsg(20,key,"Keynote report (python)")
                    print("message from keynote keynote_1a_yes  client:", key)
                    table_data = get_redis_data(key)

                    PostProgressMsg(30,"get redis data finish","Keynote report (python)")
                    if len(table_data)>0:
                        generate_report_for_keynote_1a_yes(table_data)
                    else:
                        print("****get keynote data error")
                        with open(filelogname, 'w') as file_object:
                            file_object.write("Finished,create keynote report error")

                        PostProgressMsg(35,"****get keynote data error","Keynote report (python)")
                    return

                if key == 'generate_keynote_1b_yes':
                    PostProgressMsg(20,key,"Keynote report (python)")
                    print("message from keynote keynote_1b_yes client:", key)
                    table_data = get_redis_data(key)
                    PostProgressMsg(30,"get redis data finish","Keynote report (python)")
                    if len(table_data)>0:
                        generate_report_for_keynote_1b_yes(table_data)
                    else:
                        print("****get keynote data error")
                        with open(filelogname, 'w') as file_object:
                            file_object.write("Finished,create keynote report error")
                        PostProgressMsg(35,"****get keynote data error","Keynote report (python)")
                    return

                if key == 'generate_keynote_1b_no':
                    PostProgressMsg(20,key,"Keynote report (python)")
                    print("message from keynote keynote_1b_no client:", key)
                    table_data = get_redis_data(key)
                    PostProgressMsg(30,"get redis data finish","Keynote report (python)")
                    if len(table_data)>0:
                        generate_report_for_keynote_1b_no(table_data)
                    else:
                        print("---get keynote data error")
                        with open(filelogname, 'w') as file_object:
                            file_object.write("Finished,create keynote report error")
                        PostProgressMsg(35,"****get keynote data error","Keynote report (python)")
                    return
                if "caculate" == key[0:8]:
                    PostProgressMsg(20,key,"Keynote report BM Check for filter")
                    print("message from keynote keynote_1b_no client:", )
                    keys= key.split("^&^")
                    itemName =  keys[1]

                    import json
                    itemInfos = json.loads(keys[2])
                    
                    currentIndex = float(keys[3])
                    totalIndex = float(keys[4])

                    infos = []
                    for key,value in itemInfos.items():
                        if "Data" in value.keys():
                            isFullData = False
                            try:
                                itemDatas = list(map(lambda x:float(x),value["Data"]))
                                isFullData = True
                            except Exception as e:
                                pass
                            if isFullData:
                                ret = calulateBM(itemDatas)
                                print("calute:{}:BM is{}".format(key,ret))
                                infos.append({"Filter":key,"BM":ret})
                            else:
                                infos.append({"Filter":key,"BM":"None"})
                            
                        else:
                            print("calute:{}:BM is{}".format(key,"None"))
                            infos.append({"Filter":key,"BM":"None"})
                    global g_BMCInfoFilter
                    g_BMCInfoFilter[itemName] = infos
                    import pandas as pd

                    dataframe = pd.DataFrame(infos)
                    dataframe.to_csv("/tmp/CPK_Log/temp/{}.csv".format(itemName),index=False,sep=',')




            else:
                time.sleep(0.05)

        except Exception as e:
            PostJsonInfo( "exception^&^" + str(e))
            print('error keynote:',e)
            filelogname = '/tmp/CPK_Log/temp/.keynote.txt'
            with open(filelogname, 'w') as file_object:
                file_object.write("Finished,create keynote error: " + str(e))
            #PostProgressMsg(100,"exception {}".format(e).replace("\t","").replace("\n",""),"Keynote report (python)")

if __name__ == '__main__':
    # t1 = threading.Thread(target=run, args=("<<correlation>>",))
    # t1.start()
    run(0)

