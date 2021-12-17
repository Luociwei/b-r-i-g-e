#! /usr/bin/env python3
# --*-- coding: utf-8 ---*---

import sys,os,time,math,re

import time
import threading

BASE_DIR=os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0,BASE_DIR+'/site-packages/')

try:
    import csv
except Exception as e:
    print('e---->',e)

print('python import ---->matplotlib')
try:
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
except Exception as e:
    print('e---->',e)

print('python import ----> matplotlib.colors')
try:
    import matplotlib.colors as colors
except Exception as e:
    print('e---->',e)

print('python import ----> FontProperties')
try:
    from matplotlib.font_manager import FontProperties
except Exception as e:
    print('e---->',e)


print('python import ----> numpy')
try:
    import numpy as np
except Exception as e:
    print('e--->',e)

print('python import ----> pandas')
try:
    import pandas as pd
except Exception as e:
    print('e--->',e)

print('python import ----> openpyxl')
try:
    import openpyxl
except Exception as e:
  print('import openpyxl error:',e)
print('python import ----> xlsxwriter')
try:
    import xlsxwriter
except Exception as e:
  print('import xlsxwriter error:',e)

print('python import ----> diptest')
try:
    import diptest
except Exception as e:
    print('import diptest error:',e)

try:
    import zmq
except Exception as e:
    print('import zmq error:',e)
print('python import ----> zmg')

try:
    import redis
except Exception as e:
    print('import redis error:',e)
print('python import ----> redis')

print(sys.getdefaultencoding())





# import zmq
# import redis

redisClient = redis.Redis(host='localhost', port=6379, db=0)

context = zmq.Context()
socket = context.socket(zmq.REP)
socket.setsockopt(zmq.LINGER,0)
socket.bind("tcp://127.0.0.1:3100")

filelogname = ''

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

def cpk_plot(table_data,zmqMsg):
    try:
        global filelogname
        info = ''
        i_start = [i for i,x in enumerate(table_data) if x=='Start_Data']
        i_stop = [i for i,x in enumerate(table_data) if x=='End_Data']
        tbdata=[]  #取出数据
        for i, v in enumerate(i_start):  #因start_data和End_data成对出现
            tbdata.append(table_data[i_start[i]-36:i_stop[i]])

        item_name=tbdata[0][1]
        usl = tbdata[0][4]
        lsl = tbdata[0][5]
        set_bins = tbdata[0][19]
        path= tbdata[0][30]
        filelogname = path + '/temp/.logcpk.txt'
        start_time_first = tbdata[0][21]
        start_time_last = tbdata[0][22]

        select_new_lsl = tbdata[0][7]
        select_new_usl = tbdata[0][8]
        limit_apply = tbdata[0][9]   #是否点击了UI apply
        select_color_by = tbdata[0][31]   #是否点击了color by left
        select_color_by_right = tbdata[0][32]   #是否点击了color by right

        zoom_type = tbdata[0][18]
        if limit_apply == 1:
            lsl = select_new_lsl
            usl = select_new_usl

        print("----select color by cpk:",select_color_by,select_color_by_right)
        if select_color_by >0 or select_color_by_right>0:  # color by choose
            tb_data_raw=[]  #取出数据
            for i, v in enumerate(i_start):  #因start_data和End_data成对出现
                tb_data_raw.append(table_data[i_start[i]+1:i_stop[i]])
            # print("++++",tb_data_raw)

            tb_data2=[]
            for i,v in enumerate(tb_data_raw): # 删除列表空值
                tmp = [i for i in v if i !='']  
                tb_data2.append(tmp)
            # print(tb_data2)
            all_data = ([i for item in tb_data2 for i in item]) # 二维列表拼接成一维列表
            # print(all_data)

            mean, max_num, min_num, stdev, x1, y1, cpu, cpl, cpk = cpk_calc(all_data, lsl, usl)
            # if stdev == 0:
            #     info = item_name+'stdv == 0 cannot calculate cpk!'
            #     print(info)
            #     with open(filelogname, 'w') as file_object:
            #         file_object.write("FAIL,stdv == 0 cannot calculate cpk")
            #     # redisClient.set("cpk_png",'stdv == 0 cannot calculate cpk')
            #     return info
            # else:
            image_name ='cpk.png'
            pic_path = path +'/temp/'
            pic_path = pic_path + image_name
            zmqItem = zmqMsg.split('##')
            print("-->>>zmqMsg:",zmqMsg)
            draw_more_histogram(tb_data2,all_data,zmqItem,item_name,lsl, usl, mean, max_num, min_num, stdev, x1, y1, cpu, cpl, cpk, pic_path,set_bins,start_time_first,start_time_last,zoom_type)

        else:   #没有选择color by

            # print(table_data) 
            tb_raw_data = tbdata[0][37:]  #注意 原始数据有空值
            # print("********",tb_raw_data)
            tb_data=[]
            # for i,v in enumerate(tb_raw_data): # 删除列表空值
            #     tmp = [i for i in v if i !='']  
            #     tb_data.append(tmp)
            tb_data = [i for i in tb_raw_data if i !='']  
            # print(tb_data)    # 没有空值的数据
            mean, max_num, min_num, stdev, x1, y1, cpu, cpl, cpk = cpk_calc(tb_data, lsl, usl)
            # if stdev == 0:
            #     info = item_name+'stdv == 0 cannot calculate cpk!'
            #     print(info)
            #     with open(filelogname, 'w') as file_object:
            #         file_object.write("FAIL,stdv == 0 cannot calculate cpk")
            #     # redisClient.set("cpk_png",'stdv == 0 cannot calculate cpk')
            #     return info
            # else:
            image_name ='cpk.png'
            pic_path = path +'/temp/'
            pic_path = pic_path + image_name
            draw_histogram(tb_data,item_name,lsl, usl, mean, max_num, min_num, stdev, x1, y1, cpu, cpl, cpk, pic_path,set_bins,start_time_first,start_time_last,zoom_type)



        info = 'cpk and plot draw finished!!!'
        with open(filelogname, 'w') as file_object:
            file_object.write("PASS,cpk and plot draw finished")
        return info

    except Exception as e:
        with open(filelogname, 'w') as file_object:
            file_object.write("FAIL,error cpk_plot function")
        print('error cpk_plot function:',e)


def draw_more_histogram(column_category_data_list,column_data,zmqItem,item_name, lsl, usl, mean, max_num, min_num, stdev, x1, y1,cpu, cpl, cpk, pic_path,set_bins,start_time_first,start_time_last,zoom_type):
    """

    """

    # range = get_limit_range(lsl, usl)
    # range = round((range /set_bins), 5)
    # bins = np.arange(lsl, usl, range)  # 必须是单调递增的
    bins,bins_l,bins_h = get_bins(min_num,max_num,lsl,usl,set_bins,zoom_type)

    # print('9999 column_category_data_list--->',column_category_data_list)
    # print('9999 column_data--->',len(column_data),column_data)
    # print('9999 bins len--->',len(bins))

    # print(len(column_data),'---->',min(column_data),max(column_data),bins)
    probability_distribution_extend_by_color(column_category_data_list,column_data,zmqItem,bins, 0, item_name, lsl, usl, mean, max_num, min_num, stdev, x1, y1, cpu, cpl, cpk, pic_path,bins_l,bins_h,start_time_first,start_time_last,zoom_type)

    return True

def probability_distribution_extend_by_color(column_category_data_list,data,zmqItem,bins,margin,item_name,lsl,usl,mean,max_num,min_num,stdev,x1,y1,cpu,cpl,cpk,pic_path,bins_l,bins_h,start_time_first,start_time_last,zoom_type):
    # print('one column data len:',len(data),item_name,data,column_category_data_list)
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
    plt.title("probability-distribution")
    plt.bar(bins, intervals,color=['r'], label='')#频率分布
    x_ticks,labels = plt.xticks()
    x_ticks_start=round(x_ticks[0],2)
    x_ticks_end = round(x_ticks[len(x_ticks) - 1],2)
    y_ticks, labels = plt.yticks()
    # print('y_ticks--->',y_ticks,y_ticks[len(y_ticks) - 1],y_ticks[0])
    y_ticks=round(y_ticks[len(y_ticks) - 1],5)
    # print("x_ticks_start,x_ticks_end--->",x_ticks_start,x_ticks_end)
    # print('y_ticks_end--->',y_ticks)
    # plt.show()
    plt.close(1)


    plt.figure(2,dpi=150)  # 创建图表2,facecolor='blue',edgecolor='black'

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

    info = "Sample: " + sample_n + '\n' +"Max: " + max_num + '\n' + "Mean: " + mean + '\n' + "Min: " + min_num + '\n' + "Std: " + stdev + '\n' + "Cpl: " + cpl_value + '\n' + "Cpu: " + cpu_value + '\n' + "Cpk: " + cpk_value
    # info = "Sample: " + str("%.f" % len(data)) + '\n' +"Max: " + str("%.3f" % max_num) + '\n' + "Mean: " + str("%.3f" % mean) + '\n' + "Min: " + str(
    #     "%.3f" % min_num) + '\n' + "Std: " + str("%.3f" % stdev) + '\n' + "Cpl: " + str(
    #     "%.3f" % cpl) + '\n' + "Cpu: " + str("%.3f" % cpu) + '\n' + "Cpk: " + str("%.3f" % cpk)
    item_name = str(item_name)
    if len(item_name) > 55:
        item_name = item_name[0:55] + '\n' + item_name[55:]
    # font = FontProperties(fname=r"/Library/Fonts/Songti.ttc", size=12)
    plt.title(item_name,size=10)
    plt.xlabel(str(start_time_first)+' -- '+str(start_time_last))
    plt.ylabel('Count')

    # plt.title(item_name+"\nCpk={0}".format(str("%.6f" % cpk)))
    # plt.hist(x=data, bins=bins, density=False, histtype='bar', color=['r'])
    bins = [round(x,5) for x in bins]
    bins=sorted(bins)
    # print('----->bins-->',bins)
    # print(' more draw category data:',len(column_category_data_list),column_category_data_list)
    color_l = ['#0000FF','#FF0000','#008000','#00FFFF','#9400D3','#8B008B','#B8860B','#FFA500','#A9A9A9','#FFFF00']

    l=0
    l_len=[]
    x = 0
    for category_data in column_category_data_list:
        # print('category_test_data--->', category_data[5:])
        # print('category_name,category_color--->', category_data[0],str(category_data[1]))
        # category_name,category_color = category_data[0],str(category_data[1])
        category_color = color_l[x%10]
        n=len(category_data)
        l=l+n
        # print('category len:',n)
        l_len.append(n)
        if len(column_category_data_list) == 1:
            plt.hist(category_data, bins=bins, label=zmqItem[x], color=category_color ,histtype='stepfilled',edgecolor=category_color,linewidth=1.5,align='mid',density=False) #time分布
        else:
            plt.hist(category_data, bins=bins, label=zmqItem[x], color='white' ,histtype='step',edgecolor=category_color,linewidth=1.5,align='mid',density=False) #time分布
        x=x+1
    # print('----->a column len,max in one category:-->',l,max(l_len))

   
    y_ticks = max(l_len) * (y_ticks+0.04)
    range_value = get_limit_range(bins_l, bins_h)
    range_value =round(range_value/5,5)
    # print('plot bar--->',bins_l,range)
    if float(min_num) >0 and float(max_num) >0 and zoom_type =='data':
        plt.xlim(float(min_num)*0.9, float(max_num)*1.1)
    else:
        plt.xlim(bins_l-range_value, bins_h+range_value)
    plt.ylim((0, y_ticks))  # 设置y轴scopex

    ax=plt.gca()
    ax.spines['bottom'].set_linewidth(1.5)
    ax.spines['left'].set_linewidth(1.5)
    ax.spines['right'].set_linewidth(1.5)
    ax.spines['top'].set_linewidth(1.5)

    # plt.plot(x1, y1, 'k--', label="", linewidth=1.0, color='lime')  # 画正态分布曲线
    if lsl !='NA' and usl != 'NA' and zoom_type=='limit':
        plt.plot([lsl, lsl, ], [0, y_ticks, ], 'k--', linewidth=3.0, color='red')  # 画lower limit线，
        plt.plot([usl, usl, ], [0, y_ticks, ], 'k--', linewidth=3.0, color='red')  # 画upper limit线，
        # 添加文字
        # plt.text(0.1,20, r'$\mu=100,\ \sigma=15$')
        plt.text(lsl, y_ticks / 3, ' LSL\n' + ' ' + str(lsl), fontdict={'size': 10, 'color': 'r'})
        plt.text(usl, y_ticks / 2, ' USL\n' + ' ' + str(usl), fontdict={'size': 10, 'color': 'r'})
        # plt.axis([-0.2, 0.2,0, 100])#x 轴，y 轴

    plt.text(bins_l+range_value/3, y_ticks*0.78, info, size=10, rotation=0.0, alpha=0.85,fontsize=8,ha="left",
             va="center",bbox=dict(boxstyle="round", ec=('royalblue'),linestyle='-.',lw=1, fc=('white'), ))



    #os.system('mkdir fail')
    if len(column_category_data_list) < 30:    
        plt.legend(loc="upper right",framealpha=1,edgecolor='royalblue',borderaxespad=0.3,fontsize=6)#facecolor ='None',

    # plt.legend(bbox_to_anchor=(1.01, 1), loc=2, borderaxespad=0)

    plt.grid(linestyle=':',c='gray')  # 生成网格
    # path="/Users/rex/PycharmProjects/my/fail/"

    plt.savefig(pic_path,dpi=200)
    plt.draw()

    # plt.show()
    plt.close('all')

    plt.ioff() 


    
# def probability_distribution_extend_by_color(column_category_data_list,data,zmqItem,bins,margin,item_name,lsl,usl,mean,max_num,min_num,stdev,x1,y1,cpu,cpl,cpk,pic_path,bins_l,bins_h,start_time_first,start_time_last,zoom_type='limit'):
#     # print('one column data len:',len(data),data)
#     bins = sorted(bins)
#     length = len(bins)
#     intervals = np.zeros(length+1)
#     for value in data:
#         i = 0
#         while i < length and value >= bins[i]:
#             i += 1
#         intervals[i] += 1
#     intervals = intervals / float(len(data))
#     plt.ion()  # 开启interactive mode

#     plt.figure(1)  # 创建图表1
#     plt.xlim(min(bins) - margin, max(bins) + margin)
#     bins.insert(0, -999)
#     plt.title("probability-distribution")
#     plt.bar(bins, intervals,color=['r'], label='')#频率分布
#     x_ticks,labels = plt.xticks()
#     x_ticks_start=round(x_ticks[0],2)
#     x_ticks_end = round(x_ticks[len(x_ticks) - 1],2)
#     y_ticks, labels = plt.yticks()
#     # print('y_ticks--->',y_ticks,y_ticks[len(y_ticks) - 1],y_ticks[0])
#     y_ticks=round(y_ticks[len(y_ticks) - 1],5)
#     # print("x_ticks_start,x_ticks_end--->",x_ticks_start,x_ticks_end)
#     # print('y_ticks_end--->',y_ticks)
#     # plt.show()
#     plt.close(1)
#     plt.figure(2,dpi=150)  # 创建图表2,facecolor='blue',edgecolor='black'

#     if cpl ==None:
#         cpl_value =''
#     else:
#         cpl_value = str("%.3f" % cpl)

#     if cpu ==None:
#         cpu_value =''
#     else:
#         cpu_value = str("%.3f" % cpu)

#     if cpk ==None:
#         cpk_value =''
#     else:
#         cpk_value = str("%.3f" % cpk)

#     info = "Sample: " + str("%.f" % len(data)) + '\n' +"Max: " + str("%.3f" % max_num) + '\n' + "Mean: " + str("%.3f" % mean) + '\n' + "Min: " + str("%.3f" % min_num) + '\n' + "Std: " + str("%.3f" % stdev) + '\n' + "Cpl: " + cpl_value + '\n' + "Cpu: " + cpu_value + '\n' + "Cpk: " + cpk_value
  


#     # info = "Sample: " + str("%.f" % len(data)) + '\n' +"Max: " + str("%.3f" % max_num) + '\n' + "Mean: " + str("%.3f" % mean) + '\n' + "Min: " + str(
#     #     "%.3f" % min_num) + '\n' + "Std: " + str("%.3f" % stdev) + '\n' + "Cpl: " + str(
#     #     "%.3f" % cpl) + '\n' + "Cpu: " + str("%.3f" % cpu) + '\n' + "Cpk: " + str("%.3f" % cpk)
#     item_name = str(item_name)
#     if len(item_name) > 60:
#         item_name = item_name[0:60] + '\n' + item_name[60:]
#     # font = FontProperties(fname=r"/Library/Fonts/Songti.ttc", size=12)
#     plt.title(item_name,size=10)
#     plt.xlabel(str(start_time_first)+' -- '+str(start_time_last))
#     plt.ylabel('Count')

#     # plt.title(item_name+"\nCpk={0}".format(str("%.6f" % cpk)))
#     # plt.hist(x=data, bins=bins, density=False, histtype='bar', color=['r'])
#     bins = [round(x,5) for x in bins]
#     bins=sorted(bins)
#     # print('----->bins-->',bins)
#     # print(' more draw category data:',len(column_category_data_list),column_category_data_list)
#     color_l = ['#0000FF','#FF0000','#008000','#00FFFF','#9400D3','#8B008B','#B8860B','#FFA500','#A9A9A9','#FFFF00']
#     l=0
#     l_len=[]
#     x = 0
#     for category_data in column_category_data_list:
#         # print('category_test_data--->', category_data[5:])
#         # print('category_name,category_color--->', category_data[0],str(category_data[1]))
#         # category_name,category_color = category_data[0],str(category_data[1])
#         # category_name = zmqItem[l]
#         category_color = color_l[x%10] #category_data[0],str(category_data[1])
#         n=len(category_data)
#         l=l+n
#         # print('category len:',n)
#         l_len.append(n)
#         if len(column_category_data_list) == 1:
#             plt.hist(category_data, bins=bins, label=zmqItem[x], color=category_color ,histtype='stepfilled',edgecolor=category_color,linewidth=1.5,align='mid',density=False) #time分布
#         else:
#             plt.hist(category_data, bins=bins, label=zmqItem[x], color='white' ,histtype='step',edgecolor=category_color,linewidth=1.5,align='mid',density=False) #time分布
#         # print('----->a column len,max in one category:-->',l,max(l_len))
#         x=x+1
 
#     y_ticks = max(l_len) * (y_ticks+0.04)
#     range_value = get_limit_range(bins_l, bins_h)
#     range_value =round(range_value/5,5)
#     # print('plot bar--->',bins_l,range)
#     plt.xlim(bins_l-range_value, bins_h+range_value)
#     plt.ylim((0, y_ticks))  # 设置y轴scopex

#     ax=plt.gca()
#     ax.spines['bottom'].set_linewidth(1.5)
#     ax.spines['left'].set_linewidth(1.5)
#     ax.spines['right'].set_linewidth(1.5)
#     ax.spines['top'].set_linewidth(1.5)

#     # plt.plot(x1, y1, 'k--', label="", linewidth=1.0, color='lime')  # 画正态分布曲线
#   #   if lsl !='NA' and usl != 'NA':
# #         plt.plot([lsl, lsl, ], [0, 1000000, ], 'k--', linewidth=3.0, color='red')  # 画lower limit线，
# #         plt.plot([usl, usl, ], [0, 1000000, ], 'k--', linewidth=3.0, color='red')  # 画upper limit线，
# #         # 添加文字
# #         # plt.text(0.1,20, r'$\mu=100,\ \sigma=15$')
# #         plt.text(lsl, y_ticks / 3, ' LSL\n' + ' ' + str(lsl), fontdict={'size': 10, 'color': 'r'})
# #         plt.text(usl, y_ticks / 2, ' USL\n' + ' ' + str(usl), fontdict={'size': 10, 'color': 'r'})
# #         # plt.axis([-0.2, 0.2,0, 100])#x 轴，y 轴
#     if lsl !='NA' and usl != 'NA' and zoom_type=='limit':
#         plt.plot([lsl, lsl, ], [0, y_ticks, ], 'k--', linewidth=3.0, color='red')  # 画lower limit线，
#         plt.plot([usl, usl, ], [0, y_ticks, ], 'k--', linewidth=3.0, color='red')  # 画upper limit线，
#         # 添加文字
#         # plt.text(0.1,20, r'$\mu=100,\ \sigma=15$')
#         plt.text(lsl, y_ticks / 3, ' LSL\n' + ' ' + str(lsl), fontdict={'size': 10, 'color': 'r'})
#         plt.text(usl, y_ticks / 2, ' USL\n' + ' ' + str(usl), fontdict={'size': 10, 'color': 'r'})
#         # plt.axis([-0.2, 0.2,0, 100])#x 轴，y 轴

#     plt.text(bins_l+range_value/3, y_ticks*0.78, info, size=10, rotation=0.0, alpha=0.85,fontsize=8,ha="left",va="center",bbox=dict(boxstyle="round", ec=('royalblue'),linestyle='-.',lw=1, fc=('white'), ))

#     #os.system('mkdir fail')
#     if len(column_category_data_list) < 30:    
#         plt.legend(loc="upper right",framealpha=1,edgecolor='royalblue',borderaxespad=0.3,fontsize=6)
#     # plt.legend(bbox_to_anchor=(1.01, 1), loc=2, borderaxespad=0)

#     plt.grid(linestyle=':',c='gray')  # 生成网格
#   # path="/Users/rex/PycharmProjects/my/fail/"
#     plt.savefig(pic_path,dpi=200)
#     plt.draw()
#     # plt.show()
#     plt.close('all')
#     plt.ioff()  

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
        return (mean,max_num,min_num,stdev,None,None,None,None,None)
    else:
        try:
            stdev = np.std(df_data,ddof=1,axis=0)
        except Exception as e:
            return (mean,max_num,min_num,stdev,None,None,None,None,None)


    # print('stdev ---->',stdev)
    if stdev == 0:#stop count cpk
        return (mean,max_num,min_num,stdev,None,None,None,None,None)
    # 生成横轴数据平均分布
    # x1 = np.linspace(mean - sigma * stdev, mean + sigma * stdev, 1000)
    # print('x1 ---->',x1)
    # 计算正态分布曲线
    # y1 = np.exp(-(x1 - mean) ** 2 / (2 * stdev ** 2)) / (math.sqrt(2 * math.pi) * stdev)
    # print('y1 ---->',y1)
    x1,y1 = None,None

    if lsl == 'NA' or usl == 'NA' or lsl == '' or usl == '':
        return (mean,max_num,min_num,stdev,None,None,None,None,None)
    cpu = (usl - mean) / (sigma * stdev)
    cpl = (mean - lsl) / (sigma * stdev)
    # print('cpu ---->',cpu)
    # print('cpl ---->',cpl)

    # 得出cpk
    cpk = min(cpu, cpl)
    return (mean,max_num,min_num,stdev,x1,y1,cpu,cpl,cpk)



def draw_histogram(column_data,item_name,lsl,usl,mean,max_num,min_num,stdev,x1,y1,cpu,cpl,cpk,pic_path,set_bins,start_time_first,start_time_last,zoom_type='limit'):


    bins,bins_l,bins_h = get_bins(min_num,max_num,lsl,usl,set_bins,zoom_type)
    # print(len(column_data),'---->',min(column_data),max(column_data),bins)
    probability_distribution_extend(column_data,bins,0,item_name,lsl,usl,mean,max_num,min_num,stdev,x1,y1,cpu,cpl,cpk,pic_path,bins_l,bins_h,start_time_first,start_time_last,zoom_type)

    return True

def get_bins(min_num,max_num,lsl,usl,set_bins,zoom_type='limit'):
    print('min_num,max_num,lsl,usl,set_bins=====>',min_num,max_num,lsl,usl,set_bins)

    bins_l = 0
    bins_h = 0
    if lsl == 'NA' or usl == 'NA' or lsl == '' or usl == '' or zoom_type == 'data':
        bins_l,bins_h = min_num,max_num

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
          

    else:
        if range_value == 0 and lsl !=0:
            range_value = lsl*0.2
            bins_l = bins_l - lsl*0.1
            bins_h = bins_h + usl*0.1
        elif range_value == 0 and lsl ==0:
            range_value = 6
            bins_l =  - 3
            bins_h = 3


    print('range_value1-->',range_value)
    range_value = round((range_value/set_bins),12)
    print('range_value2-->',range_value)
    print('=====>',bins_l,bins_h,range_value)
    bins = np.arange(bins_l, bins_h, range_value)#必须是单调递增的
    print('lsl,usl,min_num,max_num,bins_l,bins_h in get_bins=====>',lsl,usl,min_num,max_num,bins_l,bins_h)
    return bins,bins_l,bins_h


def probability_distribution_extend(data,bins,margin,item_name,lsl,usl,mean,max_num,min_num,stdev,x1,y1,cpu,cpl,cpk,pic_path,bins_l,bins_h,start_time_first,start_time_last,zoom_type='limit'):
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
    plt.title("probability-distribution")
    plt.bar(bins, intervals,color=['r'], label='')#频率分布
    x_ticks,labels = plt.xticks()
    x_ticks_start=round(x_ticks[0],2)
    x_ticks_end = round(x_ticks[len(x_ticks) - 1],2)
    y_ticks, labels = plt.yticks()
    # print('y_ticks--->',y_ticks,y_ticks[len(y_ticks) - 1],y_ticks[0])
    y_ticks=round(y_ticks[len(y_ticks) - 1],5)
    # print("x_ticks_start,x_ticks_end--->",x_ticks_start,x_ticks_end)
    # print('y_ticks_end--->',y_ticks)
    # plt.show()
    plt.close(1)


    # plt.figure(2,dpi=150)  # 创建图表2
    # if cpl ==None:
    #     cpl_value =''
    # else:
    #     cpl_value = str("%.3f" % cpl)

    # if cpu ==None:
    #     cpu_value =''
    # else:
    #     cpu_value = str("%.3f" % cpu)

    # if cpk ==None:
    #     cpk_value =''
    # else:
    #     cpk_value = str("%.3f" % cpk)

    # info = "Sample: " + str("%.f" % len(data)) + '\n' +"Max: " + str("%.3f" % max_num) + '\n' + "Mean: " + str("%.3f" % mean) + '\n' + "Min: " + str("%.3f" % min_num) + '\n' + "Std: " + str("%.3f" % stdev) + '\n' + "Cpl: " + cpl_value + '\n' + "Cpu: " + cpu_value + '\n' + "Cpk: " + cpk_value
    # # info = "Sample: " + str("%.f" % len(data)) + '\n' +"Max: " + str("%.3f" % max_num) + '\n' + "Mean: " + str("%.3f" % mean) + '\n' + "Min: " + str(
    # #     "%.3f" % min_num) + '\n' + "Std: " + str("%.3f" % stdev) + '\n' + "Cpl: " + str(
    # #     "%.3f" % cpl) + '\n' + "Cpu: " + str("%.3f" % cpu) + '\n' + "Cpk: " + str("%.3f" % cpk)
    # if len(item_name) > 60:
    #     item_name = item_name[0:60] + '\n' + item_name[60:]
    # # font = FontProperties(fname=r"/Library/Fonts/Songti.ttc", size=12)
    # # plt.title(item_name,FontProperties=font)
    # plt.title(item_name,size=10)
    # plt.xlabel(str(start_time_first)+' -- '+str(start_time_last))
    # plt.ylabel('Count')
    # # plt.title(item_name+"\nCpk={0}".format(str("%.6f" % cpk)))
    # # plt.hist(x=data, bins=bins, density=False, histtype='bar', color=['r'])
    # bins = [round(x,5) for x in bins]
    # bins=sorted(bins)
    # # print('----->bins-->',bins)
    # plt.hist(data, bins=bins, label=info, histtype='stepfilled',color = 'blue', edgecolor='blue', linewidth=1.5,align='mid',density=False) #time分布

    # range_value = get_limit_range(bins_l, bins_h)
    # range_value =round(range_value/5,5)
    # # print('plot bar--->',bins_l,range)
    # plt.xlim(bins_l-range_value, bins_h+range_value)

    # y_ticks = len(data) * y_ticks
    # plt.ylim((0, y_ticks))  # 设置y轴scopex
    # ax=plt.gca()
    # ax.spines['bottom'].set_linewidth(1.5)
    # ax.spines['left'].set_linewidth(1.5)
    # ax.spines['right'].set_linewidth(1.5)
    # ax.spines['top'].set_linewidth(1.5)
    # # plt.plot(x1, y1, 'k--', label="", linewidth=1.0, color='lime')  # 画正态分布曲线
    # if lsl !='NA' and usl != 'NA' and zoom_type =='limit':
    #     plt.plot([lsl, lsl, ], [0, y_ticks, ], 'k--', linewidth=3.0, color='red')  # 画lower limit线，
    #     plt.plot([usl, usl, ], [0, y_ticks, ], 'k--', linewidth=3.0, color='red')  # 画upper limit线，

    #     # 添加文字
    #     # plt.text(0.1,20, r'$\mu=100,\ \sigma=15$')
    #     plt.text(lsl, y_ticks / 3, ' LSL\n' + ' ' + str(lsl), fontdict={'size': 10, 'color': 'r'})
    #     plt.text(usl, y_ticks / 2, ' USL\n' + ' ' + str(usl), fontdict={'size': 10, 'color': 'r'})
    #     # plt.axis([-0.2, 0.2,0, 100])#x 轴，y 轴

    # #os.system('mkdir fail')
    # plt.legend(loc="upper right",framealpha=1,edgecolor='royalblue',borderaxespad=0.3)
    # plt.grid(linestyle=':',c='gray')  # 生成网格
    # # path="/Users/rex/PycharmProjects/my/fail/"

    # plt.savefig(pic_path,dpi=200)
    # plt.draw()

    # # plt.show()
    # plt.close('all')

    # plt.ioff() 

    plt.figure(2,dpi=150)  # 创建图表2

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

    info = "Sample: " + sample_n + '\n' +"Max: " + max_num + '\n' + "Mean: " + mean + '\n' + "Min: " + min_num + '\n' + "Std: " + stdev + '\n' + "Cpl: " + cpl_value + '\n' + "Cpu: " + cpu_value + '\n' + "Cpk: " + cpk_value
    # info = "Sample: " + str("%.f" % len(data)) + '\n' +"Max: " + str("%.3f" % max_num) + '\n' + "Mean: " + str("%.3f" % mean) + '\n' + "Min: " + str(
    #     "%.3f" % min_num) + '\n' + "Std: " + str("%.3f" % stdev) + '\n' + "Cpl: " + str(
    #     "%.3f" % cpl) + '\n' + "Cpu: " + str("%.3f" % cpu) + '\n' + "Cpk: " + str("%.3f" % cpk)
    if len(item_name) > 55:
        item_name = item_name[0:55] + '\n' + item_name[55:]
    # font = FontProperties(fname=r"/Library/Fonts/Songti.ttc", size=12)
    # plt.title(item_name,FontProperties=font)
    plt.title(item_name,size=10)
    plt.xlabel(str(start_time_first)+' -- '+str(start_time_last))
    plt.ylabel('Count')
    # plt.title(item_name+"\nCpk={0}".format(str("%.6f" % cpk)))
    # plt.hist(x=data, bins=bins, density=False, histtype='bar', color=['r'])
    bins = [round(x,5) for x in bins]
    bins=sorted(bins)
    # print('----->bins-->',bins)
    plt.hist(data, bins=bins, label=info, histtype='stepfilled',color = 'blue', edgecolor='blue', linewidth=1.5,align='mid',density=False) #time分布
    
    range_value = get_limit_range(bins_l, bins_h)
    range_value =round(range_value/5,5)
    # print('plot bar--->',bins_l,range)
    if float(min_num) >0 and float(max_num) >0 and zoom_type =='data':
        plt.xlim(float(min_num)*0.9, float(max_num)*1.1)
    else:
        plt.xlim(bins_l-range_value, bins_h+range_value)

    y_ticks = len(data) * y_ticks
    plt.ylim((0, y_ticks))  # 设置y轴scopex
    ax=plt.gca()
    ax.spines['bottom'].set_linewidth(1.5)
    ax.spines['left'].set_linewidth(1.5)
    ax.spines['right'].set_linewidth(1.5)
    ax.spines['top'].set_linewidth(1.5)
    # plt.plot(x1, y1, 'k--', label="", linewidth=1.0, color='lime')  # 画正态分布曲线
    if lsl !='NA' and usl != 'NA' and zoom_type =='limit':
        plt.plot([lsl, lsl, ], [0, y_ticks, ], 'k--', linewidth=3.0, color='red')  # 画lower limit线，
        plt.plot([usl, usl, ], [0, y_ticks, ], 'k--', linewidth=3.0, color='red')  # 画upper limit线，

        # 添加文字
        # plt.text(0.1,20, r'$\mu=100,\ \sigma=15$')
        plt.text(lsl, y_ticks / 3, ' LSL\n' + ' ' + str(lsl), fontdict={'size': 10, 'color': 'r'})
        plt.text(usl, y_ticks / 2, ' USL\n' + ' ' + str(usl), fontdict={'size': 10, 'color': 'r'})
        # plt.axis([-0.2, 0.2,0, 100])#x 轴，y 轴

    #os.system('mkdir fail')
    plt.legend(loc="upper right",framealpha=1,edgecolor='royalblue',borderaxespad=0.3)
    plt.grid(linestyle=':',c='gray')  # 生成网格
    # path="/Users/rex/PycharmProjects/my/fail/"

    plt.savefig(pic_path,dpi=200)
    plt.draw()

    # plt.show()
    plt.close('all')

    plt.ioff()  



def get_limit_range(lsl,usl):
    # print('lsl,usl----->', lsl, usl)
    range = 0
    if lsl < 0 and usl <= 0:
        range = abs(lsl) - abs(usl)
    elif lsl < 0 and usl >= 0:
        range = abs(lsl) + usl
    elif lsl >= 0 and (usl > 0):
        range = usl - lsl
    else:
        print('get_limit_range 00000')
    range = round(range, 5)
    # print('range in get_limit_range----->', range)
    return range

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
            print("wait for cpk client ...")
            zmqMsg = socket.recv()
            socket.send(b'cpk.png')
            if len(zmqMsg)>0:
                key = zmqMsg.decode('utf-8')
                print("message from cpk client:", key)
                table_data = get_redis_data(key)
                if len(table_data)>0:
                    cpk_plot(table_data,key)
                else:
                    print("---get data error")
                # socket.send(ret.decode('utf-8').encode('ascii'))
            else:
                time.sleep(0.05)

            # socket.send(b'cpk.png')       
        except Exception as e:
            print('error:',e)

if __name__ == '__main__':
    # t1 = threading.Thread(target=run, args=("<<cpk1>>",))
    # t1.start()
    run(0)

    # pic_path = '/Users/RyanGao/Desktop/CPK_Log/'
    # table_data = [5, 'Accelerometer AVG-FS8g_ODR200HZ_Zup accel_nmGALP_average_x', '', 1, 0.118, -0.118, 'g', '', '', 0, '', '', '', '', '', '', '', '', '', 250, '', '2020/0/0 00:00:00', '2020/0/0 10:00:00', '', '', '', '', '', '', '', '', '', '', '', '', '', 'Start_Data', 0.0087, 0.00053, -0.016106, -0.025225, 0.026282, 0.020133, -0.021225, -0.023918,'End_Data']
    # table_data = [5, 'Accelerometer AVG-FS8g_ODR200HZ_Zup accel_nmGALP_average_x', '', 1, 0.118, -0.118, 'g', '', '', 0, '', '', '', '', '', '', '', '', '', 250, '', '2020/0/0 00:00:00', '2020/0/0 10:00:00', '', '', '', '', '', '', '', '', '', '', '', '', '', 'Start_Data', 0.0087, 0.00053, 'End_Data', 5, 'Accelerometer AVG-FS8g_ODR200HZ_Zup accel_nmGALP_average_x', '', 1, 0.118, -0.118, 'g', '', '', 0, '', '', '', '', '', '', '', '', '', 250, '', '2020/0/0 00:00:00', '2020/0/0 10:00:00', '', '', '', '', '', '', '', '', '', '', '', '', '', 'Start_Data', 0.011413, -0.001426, -0.007379, 'End_Data']
    # cpk_plot(table_data,table_category_data,pic_path,set_bins,select_new_lsl,select_new_usl,start_time_first,start_time_last)
    # zmqMsg = 'Accelerometer AVG-FS8g_ODR200HZ_Zup accel_nmGALP_average_x'
    

    # zmqMsg = 'Fixture Channel ID##retest_all&remove_fail_yes'
    # table_data = get_redis_data(zmqMsg)
    # if len(table_data)>0:
    #     cpk_plot(table_data,zmqMsg)
    # else:
    #     print("---get data error")
    
    




