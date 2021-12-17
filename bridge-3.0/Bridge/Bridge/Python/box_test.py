#! /usr/bin/env python3
# --*-- coding: utf-8 ---*---


errorMsgs = ''
try:
    import sys,os,time,math,re
except Exception as e:
    print('e---->',e)
    errorMsgs = str(e)+'\r\n'

BASE_DIR=os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0,BASE_DIR+'/site-packages/')

from post import *
try:
    import datetime
except Exception as e:
    print('e---->',e)
    errorMsgs = errorMsgs + str(e) +'\r\n'

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
try:
    import time
except Exception as e:
    print('e---->',e)
    errorMsgs = errorMsgs + str(e) +'\r\n'
try:    
    import threading
except Exception as e:
    print('e---->',e)
    errorMsgs = errorMsgs + str(e) +'\r\n'



try:
    import csv
except Exception as e:
    print('e---->',e)
    errorMsgs = errorMsgs + str(e) +'\r\n'

# print('python import ---->matplotlib')
try:
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
except Exception as e:
    print('e---->',e)
    errorMsgs = errorMsgs + str(e) +'\r\n'

# print('python import ----> matplotlib.colors')
try:
    import matplotlib.colors as colors
except Exception as e:
    print('e---->',e)
    errorMsgs = errorMsgs + str(e) +'\r\n'

# print('python import ----> FontProperties')
try:
    from matplotlib.font_manager import FontProperties
except Exception as e:
    print('e---->',e)
    errorMsgs = errorMsgs + str(e) +'\r\n'


# print('python import ----> numpy')
try:
    import numpy as np
except Exception as e:
    print('e--->',e)
    errorMsgs = errorMsgs + str(e) +'\r\n'

# print('python import ----> pandas')
try:
    import pandas as pd
except Exception as e:
    print('e--->',e)
    errorMsgs = errorMsgs + str(e) +'\r\n'

# print('python import ----> openpyxl')
try:
    import openpyxl
except Exception as e:
    print('import openpyxl error:',e) 
    errorMsgs = errorMsgs + str(e) +'\r\n'

# print('python import ----> xlsxwriter')
try:
    import xlsxwriter
except Exception as e:
    print('import xlsxwriter error:',e)
    errorMsgs = errorMsgs + str(e) +'\r\n'

# print('python import ----> diptest')
try:
    import diptest
except Exception as e:
    print('import diptest error:',e)
    errorMsgs = errorMsgs + str(e) +'\r\n'

# print('python import ----> zmg')    
try:
    import zmq
except Exception as e:
    print('import zmq error:',e)
    errorMsgs = errorMsgs + str(e) +'\r\n'

# print('python import ----> redis')
try:
    import redis
except Exception as e:
    print('import redis error:',e)
    errorMsgs = errorMsgs + str(e) +'\r\n'

print('check for error Msgs module:',errorMsgs)
userdocuments = os.path.join(os.path.expanduser("~"), 'Documents')
with open(userdocuments + '/.errormodule.txt', 'w') as file_obj:
    file_obj.write(errorMsgs)

print(sys.getdefaultencoding())


redisClient = redis.Redis(host='localhost', port=6379, db=0)

context = zmq.Context()
socket = context.socket(zmq.REP)
socket.setsockopt(zmq.LINGER,0)
socket.bind("tcp://127.0.0.1:3200")

filelogname = '/tmp/CPK_Log/temp/.logbox.txt'


from post import *



g_box_datas = None

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

def normfun(x, mu, sigma):
    pdf = np.exp(-((x-mu)**2)/(2*sigma**2))/(sigma*np.sqrt(2*np.pi))
    return pdf

def dropUnFloat(x):
    bRet = False
    try:
        float(x)
        bRet = True
    except Exception as e:
        bRet = False
    return bRet
        
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
    print("check in get_coefficients",value_l)
    if len(value_l) <= 3:
        return '','','','',''

    value_l = list(map(lambda y:float(y), filter(lambda x:dropUnFloat(x),value_l)))
    
    column_stdev = np.std(value_l,ddof=1,axis=0)

    print("check in get_coefficients.  1 ....")
    three_sigma= 3*column_stdev
    # print('three_sigma:',column_stdev,three_sigma)
    temp_l= value_l
    if len(value_l) < 10:
        temp_l = value_l + value_l
        if len(temp_l)<10:
            temp_l = value_l + value_l + value_l + value_l+value_l + value_l + value_l + value_l+value_l + value_l


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
    print("check in get_coefficients.  2")
    item_name ='value1'
    data = pd.DataFrame({item_name:value_l})
    # print('data--->',type(data),data)
    u1 = data[item_name].mean() # 计算均值


    n= float(len(value_l))

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
            # print('three_CV:',three_CV)
            return 'Nan',str(p_val),'Nan','Nan',str(round(three_CV,6))
    else:
        try:
            m3 = np.sqrt(n*(n-1))/(n-2)*((1/n*sum_item_l_2)/np.sqrt(1/n*sum_item_l_1)**3)

            m4 = ((n-1)/((n-2)*(n-3)))*((n+1)*1/n*sum_item_l_3/(1/n*sum_item_l_1)**2-3*(n-1))#(d6/d7)*d16

            bc =(m3**2+1)/(m4+3*((n-1)**2/((n-2)*(n-3))))

            a_L=0.05
            a_M=0.1
            a_U=0.32
            a_Q = (a_U-a_L)*bc**2+a_L

            a_irr = np.sqrt((a_U-a_L)**2*bc)+a_L

        except Exception as e:

            if abs(u1) == 0:
                return 'Nan',str(p_val),'Nan','Nan','Nan'
            else:
                three_CV = three_sigma*100/abs(u1)

                return 'Nan',str(p_val),'Nan','Nan',str(round(three_CV,6))

    print("check in get_coefficients.  3")
    if abs(u1) == 0:
        return str(round(bc,6)),str(p_val),str(round(a_Q,6)),str(round(a_irr,6)),'Nan'
    else:
        three_CV = three_sigma*100/abs(u1)
        # print('three_CV:',three_CV)
        return str(round(bc,6)),str(p_val),str(round(a_Q,6)),str(round(a_irr,6)),str(round(three_CV,6))


def plot_display_y_name(zmqSelectItems,filter1,filter2,tb_data2_len):
    scatter_item = []
    for v in zmqSelectItems:
        filterItems = v.split('&')
        i = 0
        for z in filterItems:
            if i%2 ==0:
                if filter1[0] == 'Station ID':
                    tmpFilter1 = filterItems[i].split('-')
                    tmpFilter1_len = len(tmpFilter1)
                    if tmpFilter1_len>2:
                        tmpFilter1_str = []
                        for x in range(2,tmpFilter1_len):
                            if x==2:
                                tmpFilter1_str.append(tmpFilter1[x])
                            else:
                                tmpFilter1_str.append('-')
                                tmpFilter1_str.append(tmpFilter1[x])
                        filter_str1=''.join(tmpFilter1_str)
                        scatter_item.append(filter_str1)

                    elif tmpFilter1_len>1:
                        tmpFilter1_str = []
                        for x in range(1,tmpFilter1_len):
                            if x==1:
                                tmpFilter1_str.append(tmpFilter1[x])
                            else:
                                tmpFilter1_str.append('-')
                                tmpFilter1_str.append(tmpFilter1[x])
                        filter_str1=''.join(tmpFilter1_str)
                        scatter_item.append(filter_str1)
                    else:
                        scatter_item.append(tmpFilter1[0])
                else:
                    scatter_item.append(filterItems[0])
            else:
                if filter2[0] == 'Station ID':
                    tmpFilter2 = filterItems[i].split('-')
                    tmpFilter2_len = len(tmpFilter2)
                    if tmpFilter2_len>2:
                        tmpFilter2_str = []
                        for x in range(2,tmpFilter2_len):
                            if x==2:
                                tmpFilter2_str.append(tmpFilter2[x])
                            else:
                                tmpFilter2_str.append('-')
                                tmpFilter2_str.append(tmpFilter2[x])
                        filter_str2=''.join(tmpFilter2_str)
                        scatter_item.append(filter_str2)

                    elif tmpFilter2_len>1:
                        tmpFilter2_str = []
                        for x in range(1,tmpFilter2_len):
                            if x==1:
                                tmpFilter2_str.append(tmpFilter2[x])
                            else:
                                tmpFilter2_str.append('-')
                                tmpFilter2_str.append(tmpFilter1[x])
                        filter_str2=''.join(tmpFilter2_str)
                        scatter_item.append(filter_str2)
                    else:
                        scatter_item.append(tmpFilter2[0])
                else:
                    scatter_item.append(filterItems[1])
            i=i+1

    plot_scatter_item = []
    tmp = []
    x_flg = False
    for x in range(0,len(scatter_item)):
        if x%2 ==0:
            tmp = []
            x_flg = False
            if not scatter_item[x] == 'Off':
                x_flg = False
                tmp.append(scatter_item[x])
            else:
                x_flg = True
        else:
            if not scatter_item[x] == 'Off':
                if x_flg:
                    tmp.append(scatter_item[x])
                else:
                    tmp.append('&'+scatter_item[x])
            xx = int(x/2)
            if len(tb_data2_len)>xx:
                plot_scatter_item.append(''.join(tmp) + '('+str(tb_data2_len[xx])+')')
            else:
                plot_scatter_item.append(''.join(tmp))

    return plot_scatter_item

def cpk_plot(table_data,zmqMsg):
    try:
        global filelogname
        filelcpknew = '/tmp/CPK_Log/temp/.Boxnew.txt'

        info = ''
        i_start = [i for i,x in enumerate(table_data) if x=='Start_Data']
        i_stop = [i for i,x in enumerate(table_data) if x=='End_Data']
        tbdata=[]  #取出数据
        for i, v in enumerate(i_start):  #因start_data和End_data成对出现
            tbdata.append(table_data[i_start[i]-36:i_stop[i]])

        item_name=tbdata[0][1]
        usl = tbdata[0][4]
        lsl = tbdata[0][5]
        usl_orig = usl
        lsl_orig = lsl
        set_bins = tbdata[0][19]
        path= '/tmp/CPK_Log' #tbdata[0][30]
        filelogname = path + '/temp/.logBoxcpk.txt'
        start_time_first = tbdata[0][21]
        start_time_last = tbdata[0][22]

        select_new_lsl = tbdata[0][7]
        select_new_usl = tbdata[0][8]
        limit_apply = tbdata[0][9]   #是否点击了UI apply
        cpkLTHLD = tbdata[0][24]
        cpkHTHLD = tbdata[0][25]
        select_color_by = tbdata[0][31]   #是否点击了color by left
        select_color_by_right = tbdata[0][32]   #是否点击了color by right

        range_set_lsl = tbdata[0][27]   #get range lsl
        range_set_usl = tbdata[0][28]   #get range usl

        zoom_type = tbdata[0][18]

        print("what zoom : {}".format(zoom_type))
        if limit_apply == 1:
            lsl = select_new_lsl
            usl = select_new_usl
            new_cpk_item_key = item_name + '##retest_all&remove_fail_yes_new_cpk'
            table_data_cpk_raw = get_redis_data(new_cpk_item_key)

            i_start_cpk_new = [i for i,x in enumerate(table_data_cpk_raw) if x=='Start_Data']
            i_stop_cpk_new = [i for i,x in enumerate(table_data_cpk_raw) if x=='End_Data']

            table_data_cpk_new = []
            for i, v in enumerate(i_start_cpk_new):  #因start_data和End_data成对出现
                table_data_cpk_new.append(table_data_cpk_raw[i_start_cpk_new[i]-36:i_stop_cpk_new[i]])

            tb_raw_data_cpk_new = table_data_cpk_new[0][37:] 
            # print('>tb_raw_data_cpk_new:',tb_raw_data_cpk_new)
            tb_data_cpk_new = [i for i in tb_raw_data_cpk_new if i !='']
            mean_original, max_num_original, min_num_original, stdev_original, x1_original, y1_original, cpu_original, cpl_original, cpk_original = cpk_calc(tb_data_cpk_new, lsl, usl)
            print('cpk_original:',cpk_original)
            if cpk_original ==None:
                cpk_value =''
            else:
                if cpk_original > 999999:
                    cpk_value = str("%.3e" % cpk_original)
                else:
                    cpk_value = str("%.3f" % cpk_original)
            with open(filelcpknew, 'w') as file_object:
                file_object.write("DONE,"+str(cpk_value))


        if select_color_by >0 or select_color_by_right>0:  # color by choose
            print("in here ?1 ")
            tb_data_raw=[]  #取出数据
            for i, v in enumerate(i_start):  #因start_data和End_data成对出现
                tb_data_raw.append(table_data[i_start[i]+1:i_stop[i]])
            print("in here ?1 >> 1")

            tb_data2=[]
            tb_data2_len = []
            for i,v in enumerate(tb_data_raw): # 删除列表空值
                tmp = [i for i in v if (i !='' and dropUnFloat(i))]

                
                tb_data2.append(tmp)
                tb_data2_len.append(len(tmp))
            print("in here ?1 >> 2 ",tb_data2)

            all_data = ([i for item in tb_data2 for i in item]) # 二维列表拼接成一维列表
            print("in here ?1 >> 3 >> ")
            bc,p_val,a_Q,a_irr,three_CV = get_coefficients(all_data)
            print("in here ?1 >> 4 >> ")
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
            mean, max_num, min_num, stdev, x1, y1, cpu, cpl, cpk = cpk_calc(all_data, lsl, usl)
            if cpk:
                pass
            image_name ='cpk.png'
            pic_path = path +'/temp/'
            pic_path = pic_path + image_name
            zmqItem = zmqMsg.split('##')

            filter1 = ['']
            filter2 = ['']
            if select_color_by>0:
                filter1 = get_redis_data('select_filter_by_1')
            if select_color_by_right>0:
                filter2 = get_redis_data('select_filter_by_2')
            # print('filter1,filter2:',filter1,filter2,zmqMsgName)
            zmqSelectItems = plot_display_y_name(zmqItem,filter1,filter2,tb_data2_len)


            print("data count==> box:{} , labels:{}".format(len(tb_data2),zmqSelectItems[0:len(tb_data2)]))
            DrawBoxPlot('/tmp/CPK_Log/temp/cpkbox.png', tb_data2,item_name,"Box Plot",zmqSelectItems[0:len(tb_data2)])
            #else:
            #    DrawBoxPlotNew('/tmp/CPK_Log/temp/cpkbox.png',"Box Plot")

        else:   #没有选择color by
            print("in here ? ")
            tb_raw_data = tbdata[0][37:]  #注意 原始数据有空值
            tb_data=[]

            tb_data = [i for i in tb_raw_data if i !='']  
            # print(tb_data)    # 没有空值的数据
            bc,p_val,a_Q,a_irr,three_CV = get_coefficients(tb_data)
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



            mean, max_num, min_num, stdev, x1, y1, cpu, cpl, cpk = cpk_calc(tb_data, lsl, usl)
            if cpk:
                pass

            image_name ='cpk.png'
            pic_path = path +'/temp/'
            pic_path = pic_path + image_name
            
            
            DrawBoxPlot('/tmp/CPK_Log/temp/cpkbox.png', tb_data,item_name,"Box Plot")




        info = 'cpk and plot draw finished!!!'
        with open(filelogname, 'w') as file_object:
            file_object.write("PASS,cpk and plot draw finished")
        return info

    except Exception as e:
        with open(filelogname, 'w') as file_object:
            file_object.write("FAIL,error cpk_plot function")
        import sys
        
        print('error cpk_plot function:',sys.exc_info())


def draw_more_histogram(column_category_data_list,column_data,zmqItem,item_name, 
                        lsl, usl, mean, max_num, min_num, stdev, x1, y1,cpu, cpl, 
                        cpk, pic_path,set_bins,start_time_first,start_time_last,
                        bmc,zoom_type,range_set_lsl,range_set_usl,lsl_orig,usl_orig):
        
    bins,bins_l,bins_h = get_bins(min_num,max_num,lsl,usl,set_bins,zoom_type)
    range_bins,range_bins_l,range_bins_h = bins,bins_l,bins_h

    if zoom_type == 'range':
        range_bins,range_bins_l,range_bins_h = get_bins(min_num,max_num,range_set_lsl,range_set_usl,set_bins,zoom_type)

    probability_distribution_extend_by_color(column_category_data_list,column_data,zmqItem,bins, 0, item_name, 
                                            lsl, usl, mean, max_num, min_num, stdev, x1, y1, cpu, cpl, cpk, 
                                            pic_path,bins_l,bins_h,start_time_first,start_time_last,
                                            bmc,zoom_type,range_set_lsl,range_set_usl,range_bins,range_bins_l,range_bins_h,
                                            lsl_orig,usl_orig)

    return True




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

def probability_distribution_extend_by_color(column_category_data_list,data,zmqItem,bins,margin,item_name,
                                            lsl,usl,mean,max_num,min_num,stdev,x1,y1,cpu,cpl,cpk,pic_path,
                                            bins_l,bins_h,start_time_first,start_time_last,bmc,zoom_type,
                                            range_set_lsl,range_set_usl,range_bins,range_bins_l,range_bins_h,
                                            lsl_orig,usl_orig):

    max_num_orig = max_num
    min_num_orig = min_num
    mean_orig = mean
    stdev_orig = stdev
    if zoom_type == 'range':
        bins = sorted(range_bins)
        length = len(range_bins)
    else:
        bins = sorted(bins)
        length = len(bins)

    try:
        permin=round(np.percentile(data,2),3)
    except Exception as e:
        permin = ''
    try:
        permax=round(np.percentile(data,98),3)
    except Exception as e:
        permax = ''
    
    

    intervals = np.zeros(length+1)
    for value in data:
        i = 0
        while i < length and value >= bins[i]:
            i += 1
        intervals[i] += 1
    intervals = intervals / float(len(data))


    plt.ion()  # 开启interactive mode

    plt.figure(1)  # 创建图表1
    plt.xlim((0 if len(bins)==0 else min(bins))  - margin, (0 if len(bins)==0 else max(bins)) + margin)
    bins.insert(0, -999)
    # plt.title("probability-distribution")
    plt.bar(bins, intervals,color=['r'], label='')#频率分布
    x_ticks,labels = plt.xticks()
    # x_ticks_start=round(x_ticks[0],2)
    # x_ticks_end = round(x_ticks[len(x_ticks) - 1],2)
    y_ticks, labels = plt.yticks()
    # print('y_ticks--->',y_ticks,y_ticks[len(y_ticks) - 1],y_ticks[0])
    y_tick_cure=round(y_ticks[len(y_ticks) - 3],5)
    y_ticks=round(y_ticks[len(y_ticks) - 1],5)
    # print("x_ticks_start,x_ticks_end--->",x_ticks_start,x_ticks_end)
    # print('y_ticks_end--->',y_ticks)
    # plt.show()
    plt.close(1)


    plt.figure(2,dpi=150)  # 创建图表2,facecolor='blue',edgecolor='black'
    #fig, axes = plt.subplots( figsize=(6, 5), facecolor='#ccddef')
    plt.axes([0.1, 0.17, 0.65, 0.7])  # [左, 下, 宽, 高] 规定的矩形区域 （全部是0~1之间的数，表示比例）



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
    # plt.xlabel(str(start_time_first)+' -- '+str(start_time_last))
    plt.ylabel('Count')

    # plt.title(item_name+"\nCpk={0}".format(str("%.6f" % cpk)))
    # plt.hist(x=data, bins=bins, density=False, histtype='bar', color=['r'])
    bins = [round(x,5) for x in bins]
    bins=sorted(bins)
    # print('----->bins-->',bins)
    # print(' more draw category data:',len(column_category_data_list),column_category_data_list)
    color_l = ['#0000FF','#FF0000','#008000','#00FFFF','#9400D3','#8B008B','#B8860B','#FFA500','#A9A9A9','#FFFF00']
    color_dpf = ['#BF6128','#87A922','#B9CC81','#4B5D16','#5C2200','#B15F65','#8E553F','#586C08','#4D7409','#C17D95']

    l=0
    l_len=[]
    x = 0
    for category_data in column_category_data_list:

        try:
            pdf_check = redisClient.get('Set_CPK_CheckBox_PDF').decode('utf-8')
        
            if pdf_check == '1':
                category_pdf = color_dpf[x%10]

          
                xx_min = float(min(category_data))
                xx_max = float(max(category_data))
                x_axle = np.arange(xx_min,xx_max, (xx_max-xx_min)/100)
                pdf_values = normfun(x_axle, float(mean_orig), float(stdev_orig))
                cur_y_max=max(pdf_values)
                y_axle = (len(category_data) * y_tick_cure/cur_y_max)*pdf_values
                plt.plot(x_axle,y_axle,linewidth=2, color=category_pdf)
        except Exception as e:
            print('error_pdf: '+str(e))


        category_color = color_l[x%10]
        n=len(category_data)
        l=l+n
        # print('category len:',n)
        l_len.append(n)
        if len(column_category_data_list) == 1:
            if n>0:
                plt.hist(category_data, bins=bins, label=zmqItem[x], color=category_color ,histtype='stepfilled',edgecolor=category_color,linewidth=1.0,align='mid',density=False) #time分布
            else:
                plt.hist([0], bins=[0], label=zmqItem[x], color=category_color ,histtype='stepfilled',edgecolor=category_color,linewidth=1.0,align='mid',density=False)
        else:
            plt.hist(category_data, bins=bins, label=zmqItem[x], color='white' ,histtype='step',edgecolor=category_color,linewidth=1.0,align='mid',density=False) #time分布
        x=x+1

    y_ticks = (1 if len(l_len)==0 else max(l_len)) * (y_ticks+0.04)

    if zoom_type == 'range':
        range_value = get_limit_range(range_bins_l, range_bins_h)
    else:
        range_value = get_limit_range(bins_l, bins_h)

    range_value =round(range_value/5,5)

    print("???555?")

    if zoom_type =='data':
        range_offset = abs(float(max_num_orig) - float(min_num_orig))*0.2
        plt.xlim(float(min_num_orig)-float(range_offset), float(max_num_orig)+float(range_offset))

    elif zoom_type =='range':
        if (range_set_lsl =='' or range_set_lsl =='NA') and (range_set_usl!='NA'and range_set_usl!=''):
            plt.xlim(float(min_num_orig)*0.999, range_set_usl)
        elif (range_set_usl =='' or range_set_usl =='NA') and (range_set_lsl!='NA'and range_set_lsl!=''):
            plt.xlim(range_set_lsl, float(max_num_orig)*1.001)
        elif (range_set_usl =='' or range_set_usl =='NA') and (range_set_lsl=='NA'or range_set_lsl==''):
            plt.xlim(float(min_num_orig)*0.999, float(max_num_orig)*1.001)
        elif range_set_lsl == range_set_usl:
            plt.xlim(range_set_lsl, range_set_usl*1.001)
        else:
            plt.xlim(range_set_lsl, range_set_usl)

    else:
        if (lsl =='' or lsl =='NA') and (usl!='NA'and usl!=''):
            plt.xlim(float(min_num_orig)*0.999, usl+range_value)
        elif (usl =='' or usl =='NA') and (lsl!='NA'and lsl!=''):
            plt.xlim(lsl-range_value, float(max_num_orig)*1.001)
        elif (usl =='' or usl =='NA') and (lsl=='NA'or lsl==''):
            plt.xlim(float(min_num_orig)*0.999, float(max_num_orig)*1.001)
        else:
            plt.xlim(bins_l-range_value, bins_h+range_value)

    plt.ylim((0, y_ticks))  # 设置y轴scopex

    ax=plt.gca()
    ax.spines['bottom'].set_linewidth(1.0)
    ax.spines['left'].set_linewidth(1.0)
    ax.spines['right'].set_linewidth(1.0)
    ax.spines['top'].set_linewidth(1.0)

    # ax.spines['bottom'].set_position(('data', 5))  
    # ax.spines['left'].set_position(('data', 5))
    # ax.spines['right'].set_position(-5)
    # ax.spines['top'].set_position(-5)

    # plt.plot(x1, y1, 'k--', label="", linewidth=1.0, color='lime')  # 画正态分布曲线

    if lsl !='' and lsl !='NA' and zoom_type =='limit':
        plt.plot([lsl, lsl, ], [0, y_ticks, ], 'k--', linewidth=1.0, color='red')  # 画lower limit线，
        plt.text(lsl, y_ticks / 3, ' LSL\n' + ' ' + str(lsl), fontdict={'size': 8, 'color': 'r'})

    if usl != '' and usl != 'NA' and zoom_type =='limit':
        plt.plot([usl, usl, ], [0, y_ticks, ], 'k--', linewidth=1.0, color='red')  # 画upper limit线，
        plt.text(usl, y_ticks / 2, ' USL\n' + ' ' + str(usl), fontdict={'size': 8, 'color': 'r'})


    plt.text(0.0,-0.236, info,fontsize=10,ha="left",transform=ax.transAxes)

    plt.legend(bbox_to_anchor=(1.37,1),loc="upper right",fontsize=8,framealpha=1,edgecolor='royalblue',borderaxespad=0.07)
    plt.grid(linestyle=':',c='gray')  # 生成网格
    plt.tight_layout()
    plt.savefig(pic_path,dpi=200)
    plt.draw()
    # plt.show()
    plt.close('all')
    #plt.ioff() 



def verify_limit(lsl,usl):
    if lsl != None:
        lsl.replace(' ','')
    if usl != None:
        usl.replace(' ','')
    try:
        lsl = float(eval(lsl))
    except:
        lsl = None
    try:
        usl = float(eval(usl))
    except:
        usl = None
    # if type(lsl) == float and type(usl) == float:
    # print('after verify lsl===>',lsl)
    # print('after verify usl===>',usl)
    return lsl,usl



def cpk_calc(df_data,lsl,usl):
    """
    :param df_data: list
    :param usl: 数据指标上限
    :param lsl: 数据指标下限
    :return:
    """

    df_data = list(map(lambda y:float(y), filter(lambda x:dropUnFloat(x),df_data)))

    sigma = 3
    # print('limit--->',lsl,usl)
    # 数据平均值
    # print('df_data in cpk_calc:',df_data)
    mean = np.mean(df_data)#
    # mean = round(mean,3)
    # print('mean ---->',mean)

    # 数据max值
    if len(df_data)>0:
        max_num = max(df_data)
    else:
        max_num = 0
    # print('max_num ---->',max_num)

    # 数据min值
    if len(df_data)>0:
        min_num = min(df_data)
    else:
        min_num = 0
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
        return (mean,max_num,min_num,stdev,None,None,None,cpl,cpl)

    if (usl != 'NA' and usl != '') and (lsl == 'NA' or  lsl == ''):
        # print('====>>>>>>=====cpu')
        cpu = (usl - mean) / (sigma * stdev)
        # print('====>>>>>>cpu',cpu)
        mean = round(mean,3)
        return (mean,max_num,min_num,stdev,None,None,cpu,None,cpu)

    if lsl == 'NA' or usl == 'NA' or lsl == '' or usl == '':
        return (mean,max_num,min_num,stdev,None,None,None,None,None)
    cpu = (usl - mean) / (sigma * stdev)
    cpl = (mean - lsl) / (sigma * stdev)
    # print('cpu ---->',cpu)
    # print('cpl ---->',cpl)

    # 得出cpk
    cpk = min(cpu, cpl)
    print("CPK >>>>>>>> l,u",cpl,cpu,cpk)
    mean = round(mean,3)
    return (mean,max_num,min_num,stdev,x1,y1,cpu,cpl,cpk)



def draw_histogram(column_data,item_name,lsl,usl,mean,max_num,min_num,
                    stdev,x1,y1,cpu,cpl,cpk,pic_path,set_bins,start_time_first,
                    start_time_last,bmc,zoom_type,range_set_lsl,range_set_usl,lsl_orig,usl_orig):


    bins,bins_l,bins_h = get_bins(min_num,max_num,lsl,usl,set_bins,zoom_type)
    range_bins,range_bins_l,range_bins_h = bins,bins_l,bins_h

    if zoom_type == 'range':
        range_bins,range_bins_l,range_bins_h = get_bins(min_num,max_num,range_set_lsl,range_set_usl,set_bins,zoom_type)

    probability_distribution_extend(column_data,bins,0,item_name,lsl,usl,mean,max_num,min_num,
                                    stdev,x1,y1,cpu,cpl,cpk,pic_path,bins_l,bins_h,start_time_first,
                                    start_time_last,bmc,zoom_type,range_set_lsl,range_set_usl,
                                    range_bins,range_bins_l,range_bins_h,lsl_orig,usl_orig)

    return True

def get_bins(min_num,max_num,lsl,usl,set_bins,zoom_type='limit'):

    bins_l = 0
    bins_h = 0

    print("get_bins 2-===> ",min_num,max_num,lsl,usl)
    if lsl == 'NA' or usl == 'NA' or lsl == '' or usl == '' or zoom_type == 'data':
        bins_l,bins_h = min_num,max_num

        print("get_bins 1",min_num,max_num,lsl,usl)

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

        elif max_num ==lsl and lsl==usl and min_num <= lsl:
            bins_l = min_num
            bins_h = usl*1.1
        print("get_bins 2",bins_l,bins_h)
    range_value = get_limit_range(bins_l,bins_h)
    if lsl == 'NA' or usl == 'NA' or  lsl == '' or usl == '' or zoom_type == 'data':
        if range_value ==0  and min_num > 0:
            range_value = min_num*0.2
            bins_l = (bins_l - min_num*0.1)
            bins_h = (bins_h + min_num*0.1)
 
        elif range_value ==0 and min_num == 0:
            range_value = 6
            bins_l =  - 3
            bins_h = 3
        elif range_value ==0 and min_num <0:
            range_value = 6
            bins_l =  min_num - 3
            bins_h =  min_num + 3
            # print('range_value0-->',range_value,min_num,bins_l,bins_h)

        else:
            if min_num > 1 and range_value < 1 and range_value !=0:
                range_value = min_num*0.05
                bins_l = (bins_l - min_num*0.025)
                bins_h = (bins_h + min_num*0.025)
            elif min_num > 0.001 and min_num < 1 and range_value < 1 and range_value !=0:
                range_value = min_num*0.2
                bins_l = (bins_l - min_num*0.1)
                bins_h = (bins_h + min_num*0.1)

            else:
                range_value = range_value*0.4
                bins_l = (bins_l - range_value*0.2)
                bins_h = (bins_h + range_value*0.2)
          
        print("get_bins 3")
    else:
        if range_value == 0 and lsl !=0:
            range_value = lsl*0.2
            bins_l = bins_l - lsl*0.1
            bins_h = bins_h + usl*0.1
        elif range_value == 0 and lsl ==0:
            range_value = 6
            bins_l =  - 3
            bins_h = 3
        print("get_bins 5",range_value)

    range_value = round((range_value/set_bins),12)
    # print('range_value2-->',range_value)
    # print('=====>',bins_l,bins_h,range_value)
    print("get_bins value",range_value)
    bins = np.arange(bins_l, bins_h, range_value)#必须是单调递增的
    if bins_l<0:
        bins = np.arange(bins_h, bins_l, -range_value)
    # print('lsl,usl,min_num,max_num,bins_l,bins_h in get_bins=====>',lsl,usl,min_num,max_num,bins_l,bins_h)
    print("get_bins 5",bins,bins_l,bins_h)
    return bins,bins_l,bins_h


def probability_distribution_extend(data,bins,margin,item_name,lsl,usl,mean,max_num,
                                    min_num,stdev,x1,y1,cpu,cpl,cpk,pic_path,bins_l,bins_h,
                                    start_time_first,start_time_last,bmc,zoom_type,range_set_lsl,
                                    range_set_usl,range_bins,range_bins_l,range_bins_h,lsl_orig,usl_orig):
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
    stdev_orig = stdev
    data_orig = data
    if zoom_type =='range':
        bins = sorted(range_bins)
        length = len(range_bins)
    else:
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
    #x_ticks_start=round(x_ticks[0],2)
    #x_ticks_end = round(x_ticks[len(x_ticks) - 1],2)
    
    y_ticks, labels = plt.yticks()
    y_tick_cure=round(y_ticks[len(y_ticks) - 3],5)



    
    # print('y_tick_cure:',y_tick_cure)
    # print("x_ticks_start,x_ticks_end--->",x_ticks_start,x_ticks_end)
    # print('y_ticks--->',y_ticks)
    # plt.show()
    plt.close(1)
    plt.figure(2,dpi=150)  # 创建图表2
    #fig, axes = plt.subplots( figsize=(6, 5), facecolor='#ccddef')
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
    # plt.xlabel(str(start_time_first)+' -- '+str(start_time_last))
    plt.ylabel('Count')
    bins = [round(x,5) for x in bins]
    bins=sorted(bins)

    try:
        pdf_check = redisClient.get('Set_CPK_CheckBox_PDF').decode('utf-8')
        if pdf_check == '1':
            # if lsl_orig =='' or lsl_orig =='NA':
            #     lsl_orig = min(data_orig)
            # if usl_orig =='' or usl_orig =='NA':
            #     usl_orig = max(data_orig)
            # x_axle = np.arange(lsl_orig, usl_orig, 0.01)

            x_axle = np.arange(float(min_num_orig),float(max_num_orig), (float(max_num_orig)-float(min_num_orig))/100)
            pdf_values = normfun(x_axle, float(mean_orig), float(stdev_orig))
            cur_y_max=max(pdf_values)
            y_axle = (len(data_orig) * y_tick_cure/cur_y_max)*pdf_values
            plt.plot(x_axle,y_axle,linewidth=1, color='#FD411E')
    except Exception as e:
        print('error pdf: '+str(e))
    
    # plt.hist(data, bins=bins, label=info, histtype='stepfilled',color = 'blue', edgecolor='blue', linewidth=1.0,align='mid',density=False) #time分布
    print("check data below ===<< bins = {}\n".format(bins))
    print(data)
    print("check data finish ===>>\n")
    plt.hist(data, bins=bins, histtype='stepfilled',color = 'blue', edgecolor='blue', linewidth=1.0,align='mid',density=False) #time分布
    #plt.hist(data, bins=len(data), histtype='stepfilled',color = 'blue', edgecolor='blue', linewidth=1.0,align='mid',density=False) #time分布

    y_ticks, labels = plt.yticks()
    # print('=====y_ticks, labels:',y_ticks)
    # print('y_ticks--->',y_ticks,y_ticks[len(y_ticks) - 1],y_ticks[0])
    y_tick_cure=round(y_ticks[len(y_ticks) - 3],5)
    y_ticks=round(y_ticks[len(y_ticks) - 1],5)

    if zoom_type =='range':
        range_value = get_limit_range(range_bins_l, range_bins_h)
    else:
        range_value = get_limit_range(bins_l, bins_h)

    range_value =round(range_value/5,5)
    
    if zoom_type =='data':
        range_offset = abs(float(max_num_orig) - float(min_num_orig))*0.2
        plt.xlim(float(min_num_orig)-float(range_offset), float(max_num_orig)+float(range_offset))

        print("xlimit data")

    elif zoom_type =='range':
        if (range_set_lsl =='' or range_set_lsl =='NA') and (range_set_usl!='NA'and range_set_usl!=''):
            plt.xlim(float(min_num_orig)*0.999, range_set_usl)
        elif (range_set_usl =='' or range_set_usl =='NA') and (range_set_lsl!='NA'and range_set_lsl!=''):
            plt.xlim(range_set_lsl, float(max_num_orig)*1.001)
        elif (range_set_usl =='' or range_set_usl =='NA') and (range_set_lsl=='NA'or range_set_lsl==''):
            plt.xlim(float(min_num_orig)*0.999, float(max_num_orig)*1.001)
        elif range_set_lsl == range_set_usl:
            plt.xlim(range_set_lsl, range_set_usl*1.001)
        else:
            plt.xlim(range_set_lsl, range_set_usl)

        print("xlimit range")

    else:

        if (lsl =='' or lsl =='NA') and (usl!='NA'and usl!=''):
            plt.xlim(float(min_num_orig)*0.999, usl+range_value)
        elif (usl =='' or usl =='NA') and (lsl!='NA'and lsl!=''):
            plt.xlim(lsl-range_value, float(max_num_orig)*1.001)
        elif (usl =='' or usl =='NA') and (lsl=='NA'or lsl==''):
            plt.xlim(float(min_num_orig)*0.999, float(max_num_orig)*1.001)
        else:
            print("xlimit else ?? l:{} h:{} value:{}".format(bins_l, bins_h,range_value))
            plt.xlim(bins_l-range_value, bins_h+range_value)
        print("xlimit else")

    #y_ticks = len(data) * y_ticks
    #y_ticks =  max(data) * 
    plt.ylim((0, 1.1*y_ticks ))  # 设置y轴scopex

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
    #plt.tight_layout()
    plt.savefig(pic_path,bbox_inches='tight')#dpi=200,
    plt.draw()
    plt.close('all')
    #plt.ioff()  
def GetDiamention(select_items,data):
    filtersize = 1
    filter1 = []
    filter2 = []
    for x in range(0,len(select_items)):
        select_items[x]= re.sub("\(.*\)","",select_items[x])
        if "&" in select_items[x]:
            filters= select_items[x].split("&")

            if filters[0] not in filter1:
                filter1.append(filters[0])
            if filters[1] not in filter2:
                filter2.append(filters[1])

            filtersize =2

        else:
            if select_items[x] not in filter1:
                filter1.append(select_items[x])
            else:
                filter1.append(select_items[x]+"~")
            filtersize =1
    return filter1,filter2

def reSizeStr(input,size = 15):
    print("resize ",input)

    
    if "@" in input:
        input =  input.split("@")[1]
    elif len(input) > 8:

        replaceIndex = input.split("_")[0]
        input = input.replace(replaceIndex+"_","")
    else:
        input = input

     
    import textwrap
    input = textwrap.fill(input, 8)

    return input 

def getFontSize(filter1):
    lenSize= list(map(lambda x:len(x),filter1))
    strLen = max(lenSize)
    fsize = 10
    if len(filter1) > 15 or strLen >150:
        fsize = 5
    elif len(filter1) > 10 or strLen >120 :
        fsize = 6
    elif len(filter1) > 5 or strLen >100:
        fsize = 8
    return fsize
def DrawBoxPlot(pic_path,data,label,title,select_items = None):

    print("in Draw Box ??")
    if select_items != None:
        box_1 = data
        labels= select_items

        filter1,filter2 = GetDiamention(select_items,data)

        print("Draw More !!!!!!>>>>>>{} VS {}".format(len(select_items),len(box_1)))


        if (len(filter2) if len(filter2) >0 else 1 )==1:
            box_1 = data

            labels= [label]

            if len(filter2)==1:
                title = filter2[0]
    
            print("Draw Single !!!!!!>>>>>>> {} {} \n{}".format(len(box_1),[label],box_1))
    
            fig = plt.figure(1,dpi = 150)
            
            plt.title(title)
            fsize = getFontSize(filter1)
            plt.xticks(rotation=60,color='black',fontsize=fsize)

            filter1 = list(map(lambda x:reSizeStr(x),filter1))
            print(filter1)
            plt.boxplot(box_1, labels = filter1,boxprops = {'color':'orangered'})
            plt.grid(linestyle=':',c='gray')  # 生成网格
            #plt.margins(10,0)
        
            plt.savefig(pic_path,dpi=150,bbox_inches = 'tight')
            plt.draw()
            plt.close('all')
            plt.ioff()  
            print("finish")
        else:
            fig, axes = plt.subplots(len(filter2) if len(filter2) >0 else 1,1 ,sharex=True,sharey=True)
            plt.title(title)

            plt.subplots_adjust(left=None, bottom=None, right=None, top=None,wspace=0, hspace=0)
            print("Plot Sub !!!!!!>>>>>>> {} {}".format(len(filter2) if len(filter2) >0 else 1,1))
            if len(filter2)>0 and len(filter1)>0:

                once = 1
                
                for filteritem2 in range(0,len(filter2)):
                    #for filteritem1 in range(0,len(filter1)):
                    #print("== >1 box plot :row{} colum{} dataindex:{} datacount:{}".format(filteritem2,0,filteritem2 *len(filter1) + 0 ,len(box_1)))
                    start = filteritem2 *len(filter1) + 0
                    lens = len(filter1)
                    print("subplot draw", filteritem2,box_1[start : start+lens],filter1,axes)

                    filter1 = list(map(lambda x:reSizeStr(x),filter1))

                    print(filter1)

                    #filter1 = filter1 if once ==1 else list(map(lambda x:"",labels))

                    axes[filteritem2].boxplot(box_1[start : start+lens], labels = filter1,boxprops = {'color':'orangered'})
                    axes[filteritem2].set_title(filter2[filteritem2])
                    axes[filteritem2].grid(linestyle=':',c='gray')
                    fsize = getFontSize(filter1)
                    plt.xticks(rotation=60,color='black',fontsize=fsize)

                    once = 0
    
            elif len(filter1)<=0 or len(filter2)>0:

                once = 1
                for filteritem2 in range(0,len(filter2)):

                    label = textwrap.fill(label, 70)
                    labels= [label]
    
                    print("== >2 box plot :row{} colum{} dataindex:{} data:{}".format(filteritem2,0,0 *len(filter1) + 0 ,box_1[0 *len(filter1) + 0]))

                    
                    filterlast = list(map(lambda x:reSizeStr(x),[filter2[filteritem2]]))

                    print(filterlast)

                    #labels = labels if once ==1 else list(map(lambda x:"",labels))
                    axes[filteritem2].boxplot([box_1[filteritem2]], labels = labels,boxprops = {'color':'orangered'})
                    axes[filteritem2].set_title(filter2[filteritem2])
                    axes[filteritem2].grid(linestyle=':',c='gray')
                    plt.xticks(rotation=60,color='black',fontsize=10)

                    once = 0
    
            elif len(filter2)<=0 or len(filter1)>0:
                #for filteritem2 in range(0,len(filter2)):
                print("== > 3 box plot :row{} colum{} dataindex:{} data:{}".format(0,0,0 *len(filter1) + 0 ,box_1[0 *len(filter1) + 0]))
                filter1 = list(map(lambda j:list(map(lambda x:reSizeStr(x),j)),filter1))

                print(filter1)
                axes[0].boxplot(box_1, labels = filter1,boxprops = {'color':'orangered'})
                axes[0].grid(linestyle=':',c='gray')  # 生成网格

                fsize = getFontSize(filter1)
                plt.xticks(rotation=60,color='black',fontsize=fsize)
            
            #plt.margins(10,0)
            plt.savefig(pic_path,dpi=150,bbox_inches = 'tight')
            plt.draw()
            plt.close('all')
            plt.ioff()  
            print("DrawBoxPlot 0====>>>>:{} :label {}".format(data,label))
        
    else:
        import textwrap
        label = textwrap.fill(label, 70)

        box_1 = [data]
        labels= [label]

        #labels = list(map(lambda j:list(map(lambda x:reSizeStr(x),j)),labels))

        print("Draw Single !!!!!!>>>>>>> {} {} \n{}".format(len(box_1),labels,box_1))

        plt.figure(1,dpi=150)
        plt.title(title)

        fsize= getFontSize(labels)
        plt.xticks(color='black',fontsize=fsize)
        plt.boxplot(box_1, labels = labels,boxprops = {'color':'orangered'})
        plt.grid(linestyle=':',c='gray')  # 生成网格
        plt.legend(bbox_to_anchor=(0.9,-0.09),loc="best",fontsize=10,framealpha=0,edgecolor='royalblue',borderaxespad=0.1)
        ax=plt.gca()
        ax.spines['bottom'].set_linewidth(1)
        ax.spines['left'].set_linewidth(1)
        ax.spines['right'].set_linewidth(1)
        ax.spines['top'].set_linewidth(1)
        #plt.margins(10,0)
        plt.savefig(pic_path,dpi=150,bbox_inches = 'tight')
        plt.draw()
        plt.close('all')
        plt.ioff()
    PostJsonInfo( "box_finish^&^nothing")




    
        

        #print("DrawBoxPlot 0====>>>>:{} :label {}".format(data,label))






def checkNumber(input):
    bRet = False
    try:
        float(input)
        bRet = True
    except Exception as e:
        bRet = False
    return bRet
        
def DrawBoxPlotNew(pic_path,title):

    

    datas = list(map(lambda x:g_box_datas[x]["Data"],g_box_datas.keys()))


    datas_new = list(map( lambda data:list(filter(lambda x:checkNumber(x),data)),datas))





    
    box_1 = datas_new
    labels= g_box_datas.keys()

    print("DrawBoxPlot 0:{} {}".format(datas_new,labels))
    plt.figure(figsize=(6,5))
    plt.title(title,fontsize=20)

    print("DrawBoxPlot 1:{}".format(datas_new))
    plt.boxplot(box_1, labels = labels,boxprops = {'color':'orangered'})

    print("DrawBoxPlot 2:{}".format(datas_new))
    plt.grid(linestyle=':',c='gray')  # 生成网格
    plt.savefig(pic_path,dpi=200)
    plt.draw()
    plt.close('all')
    plt.ioff()
def get_limit_range(lsl,usl):
    # print('lsl,usl----->', lsl, usl)
    range_v = 0
    if lsl < 0 and usl <= 0:
        range_v = abs(lsl) - abs(usl)
    elif lsl < 0 and usl >= 0:
        range_v = abs(lsl) + usl
    elif lsl >= 0 and (usl > 0):
        range_v = usl - lsl
    else:
        print('get_limit_range 00000')
    range_v = round(range_v, 5)
    # print('range in get_limit_range----->', range)
    return range_v

def cpk(message):
    print("this function is generate cpk plot......")
    val = r.get(message)
    # time.sleep(5) #测试python 执行时间 5s
    if val:
        return val
    else:
        return b'None'




def run(n):
    while True:
        try:
            print("wait for box client ...")
            zmqMsg = socket.recv()
            print("box client input >> {}".format(zmqMsg))
            socket.send(b'box.png')
            if len(zmqMsg)>0:
                key = zmqMsg.decode('utf-8')
                
                table_data = get_redis_data(key)
                if len(table_data)>0:
                    cpk_plot(table_data,key)
                    
                else:
                    print(">>get data error")
                    # socket.send(ret.decode('utf-8').encode('ascii'))

            else:
                time.sleep(0.05)

            # socket.send(b'cpk.png')       
        except Exception as e:
            print('box error == >>>> Check:',e)


#def Test(data ,label=[],title="Test",select_items = ["A@1","B@2","C@3","D@4"]):


    
    plt.title(title,fontsize=20)
if __name__ == '__main__':
    # t1 = threading.Thread(target=run, args=("<<cpk1>>",))
    # t1.start()
    run(0)
    #Test()
    
    




