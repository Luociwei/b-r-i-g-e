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
socket.bind("tcp://127.0.0.1:3170")


filelogname = '/tmp/CPK_Log/temp/.logscatter.txt'

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

def plot_display_y_name(zmqSelectItems,filter1,filter2):
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
            plot_scatter_item.append(''.join(tmp))

    return plot_scatter_item

def scatter_plot(table_data, zmqMsgName):
    try:
        global filelogname
        info = ''
        i_start = [i for i,x in enumerate(table_data) if x=='Start_Data']
        i_stop = [i for i,x in enumerate(table_data) if x=='End_Data']
        tbdata=[] 
        for i, v in enumerate(i_start): 
            tbdata.append(table_data[i_start[i]-36:i_stop[i]])

        x_item_name=tbdata[0][1]

        x_usl = tbdata[0][4]
        x_lsl = tbdata[0][5]
        new_x_lsl = tbdata[0][7]
        new_x_usl = tbdata[0][8]
        limit_apply_x = tbdata[0][9]
        if limit_apply_x== 1:
            x_lsl = new_x_lsl
            x_usl = new_x_usl

        set_bins = tbdata[0][19]
        start_time_first = tbdata[0][21]
        start_time_last = tbdata[0][22]

        cpkLTHLD = tbdata[0][24]
        cpkHTHLD = tbdata[0][25]
        select_color_by_left = tbdata[0][31]   #是否点击了color by left
        select_color_by_right = tbdata[0][32]   #是否点击了color by right
        range_set_lsl = tbdata[0][27]   #get range lsl
        range_set_usl = tbdata[0][28]   #get range usl
        zoom_type = tbdata[0][18]

        path= '/tmp/CPK_Log' #tbdata[0][30]
        filelogname = path + '/temp/.logscatter.txt'
        image_name ='scatter.png'
        pic_path = path +'/temp/'
        pic_path = pic_path + image_name

        # print('select_color_by:',select_color_by_left,select_color_by_right)
        if select_color_by_left == 0 and select_color_by_right == 0:  #没有点击color by
            print('you did not choose filter 1 or filter 2,will not generate scatter plot!!!')

        else:
            filter1 = ['']
            filter2 = ['']
            if select_color_by_left>0:
                filter1 = get_redis_data('select_filter_by_1')
            if select_color_by_right>0:
                filter2 = get_redis_data('select_filter_by_2')
            print('filter1,filter2:',filter1,filter2,zmqMsgName)

            zmqSelectItems_tmp = zmqMsgName.split('##')
            zmqSelectItems = plot_display_y_name(zmqSelectItems_tmp,filter1,filter2)

            tb_val=[]  #取出数据  
            for i, v in enumerate(i_start):  #因start_data和End_data成对出现
                tb_val.append(table_data[i_start[i]+1:i_stop[i]])

            tb_data_x=[] # 二位数组
            tb_data_y=[] # 二位数组
            yy = len(tb_val)
            y_max = yy
            y_min = 1
            for i,v in enumerate(tb_val):
                tmp = [i for i in v if i !='']
                tb_data_x.append(tmp)
                tmp_y = [yy for i in v if i !='']
                tb_data_y.append(tmp_y)
                yy -=1

            if len(tb_data_x)<1:
                print("no data, can not generate plot")
                with open(filelogname, 'w') as file_object:
                    file_object.write("FAIL,no data to generate the scatter")
                return 'no date to generate plot'

            xValue = ([i for item in tb_data_x for i in item]) # 二维列表拼接成一维列表
            yValue = ([i for item in tb_data_y for i in item]) # 二维列表拼接成一维列表

            y_item_name = ''
            y_lsl = ''
            y_usl = ''
            start_time_first = ''
            start_time_last = ''

            draw_correlation_by_color(xValue,yValue,tb_data_x,tb_data_y,x_item_name,y_item_name,pic_path,
                                        x_lsl,x_usl,y_lsl,y_usl,start_time_first,start_time_last,
                                        zmqSelectItems,y_max,y_min)
            info = 'scatter plot draw finished!'
            print(info)

        with open(filelogname, 'w') as file_object:
            file_object.write("PASS,correlation plot draw finished")
        return info

    except Exception as e:
        with open(filelogname, 'w') as file_object:
            file_object.write("FAIL,error scatter_plot function")
        print('error scatter_plot function:',e)


def draw_correlation_by_color(xValue,yValue,x_category_value,y_category_value,x_item_name,y_item_name,pic_save_path,
                                x_lsl,x_usl,y_lsl,y_usl,start_time_first,start_time_last,y_item,y_max,y_min):
    
    pearson, spearman = correlation_coefficient_calc(xValue, yValue, x_item_name, y_item_name)
    plt.ion()  # 开启interactive mode
    # font = FontProperties(fname=r"/Library/Fonts/Songti.ttc", size=12)
    fig, axes = plt.subplots(1, 0, figsize=(15, 7), facecolor='#ccddef')
    # plt.axes([0.22, 0.12, 0.75, 0.75])  # [左, 下, 宽, 高] 规定的矩形区域 （全部是0~1之间的数，表示比例）
    # plt.title('Correlation pearson coefficient = ' + str(pearson)+'\n'+str(start_time_first)+' -- '+str(start_time_last),size=12)
    #plt.title('Correlation pearson coefficient = ' + str(pearson),size=13)
    plt.title('Strip plot',size=20)
    if len(x_item_name) > 70:
        x_item_name = x_item_name[0:70] + '\n' + x_item_name[70:]
    if len(y_item_name) > 45:
        y_item_name = y_item_name[0:45] + '\n' + y_item_name[45:]
    plt.xlabel(x_item_name,size=14)
    #plt.ylabel(y_item_name,size=12)
    if len(xValue)==0:
        x_min_num, x_max_num = 0,0
    else:
        x_min_num, x_max_num = min(xValue), max(xValue)
    x_ticks_l, x_ticks_h = get_ticks(x_min_num, x_max_num, x_lsl, x_usl)
    
    if x_ticks_l == x_ticks_h and x_ticks_l !=0:
       x_ticks_l = x_ticks_l - round((x_ticks_l/5.0),2)
       x_ticks_h = x_ticks_h + round((x_ticks_h/5.0),2)
    elif x_ticks_l == x_ticks_h and x_ticks_l ==0:
       x_ticks_l =  - 3
       x_ticks_h = 3
   
    plt.xlim(x_ticks_l, x_ticks_h)

    y_min_num, y_max_num = y_min,y_max#min(yValue), max(yValue)
    y_ticks_l, y_ticks_h = get_y_ticks(y_min_num, y_max_num)

    if y_ticks_l == y_ticks_h and y_ticks_l !=0:
        y_ticks_l = y_ticks_l - round((y_ticks_l/5.0),2)
        y_ticks_h = y_ticks_h + round((y_ticks_h/5.0),2)
    elif y_ticks_l == y_ticks_h and y_ticks_l ==0:
        y_ticks_l =  - 3
        y_ticks_h = 3
    plt.ylim(y_ticks_l, y_ticks_h)
    plt.tick_params(labelsize=12)

    y_name = []
    for i in range(len(y_category_value),0,-1):
        y_name.append(i)

    print(y_name)
    if len(y_item) <=25:
        plt.yticks(y_name,y_item,fontsize=12)

    elif len(y_item) >25 and len(y_item)<=35:
        plt.yticks(y_name,y_item,fontsize=11)

    elif len(y_item)>35 and len(y_item)<=50:
        plt.yticks(y_name,y_item,fontsize=10)

    elif len(y_item)>50 and len(y_item)<=70:
        plt.yticks(y_name,y_item,fontsize=8)

    elif len(y_item)>70 and len(y_item)<=85:
        plt.yticks(y_name,y_item,fontsize=6)

    elif len(y_item)>85 and len(y_item)<=100:
        plt.yticks(y_name,y_item,fontsize=4)

    else:
        plt.yticks(y_name,y_item,fontsize=2)
    
    plt.ylim(y_ticks_l, y_ticks_h)

    ax=plt.gca()
    ax.spines['bottom'].set_linewidth(1.0)
    ax.spines['left'].set_linewidth(1.0)
    ax.spines['right'].set_linewidth(1.0)
    ax.spines['top'].set_linewidth(1.0)

    if x_lsl != 'NA' and x_lsl != '':
        plt.text(x_lsl, len(y_item) / 3, ' LSL\n' + ' ' + str(x_lsl), fontdict={'size': 10, 'color': 'r'})
        plt.plot([x_lsl, x_lsl, ], [y_ticks_l, y_ticks_h, ], 'k--', linewidth=1.0, color='red') 
    if x_usl != 'NA' and x_usl != '':
        plt.text(x_usl, len(y_item) / 2, ' USL\n' + ' ' + str(x_usl), fontdict={'size': 10, 'color': 'r'})
        plt.plot([(x_lsl+x_usl)/2, (x_lsl+x_usl)/2, ], [0, len(y_item), ], 'k--', linewidth=1.5, color='red') 
        plt.text((x_lsl+x_usl)/2, 0.02, ' Center\n'+str(round((x_lsl+x_usl)/2,4)), fontdict={'size': 10, 'color': 'blue'})
        plt.plot([x_usl, x_usl, ], [y_ticks_l, y_ticks_h, ], 'k--', linewidth=1.0, color='red')  
    

    plt.rcParams['savefig.dpi'] = 250  # 图片像素
    plt.rcParams['figure.dpi'] = 150  # 分辨率
    color_l = ['#0000FF','#FF0000','#F08000','#F080FF','#9400D3','#8B008B','#B8860B','#FFA500','#A9A9A9','#FFFF00']
    for i,v in enumerate(x_category_value):
        set_color = color_l[i%10]
        plt.scatter(x_category_value[i], y_category_value[i], s=200,linewidth =1, c=set_color, marker='+')
        if len(x_category_value[i]) > 0:
            plt.text(round((min(x_category_value[i])+max(x_category_value[i]))/2,2), y_category_value[i][0]+0.2,str(len(x_category_value[i])), fontdict={'size': 10, 'color': 'black'})

    plt.grid(linestyle=':', c='gray', linewidth=1.0, alpha=0.8)  # 生成网格
    plt.tight_layout()
    plt.savefig(pic_save_path, dpi=250)
    plt.draw()
    # plt.show()
    plt.close()

    plt.ioff()

def get_y_ticks(min_val,max_val):
    ticks_l = min_val -1
    ticks_h = max_val +1
    return ticks_l, ticks_h

def get_ticks(min_num,max_num,lsl,usl):
    ticks_l = 0
    ticks_h = 0

    if lsl =='NA' or lsl =='' :
        ticks_l = min_num
    if usl =='NA' or usl =='':
        ticks_h = max_num

    if lsl !='NA' and lsl !='' and usl !='NA' and usl !='':
        if min_num < lsl and max_num < lsl:
            ticks_l = min_num
            ticks_h = usl
        elif min_num < lsl and max_num > lsl and max_num <= usl:
            ticks_l = min_num
            ticks_h = usl
        elif min_num < lsl and max_num > usl:
            ticks_l = min_num
            ticks_h = max_num
        elif lsl <= min_num and min_num <= usl and max_num <= usl:
            ticks_l = lsl
            ticks_h = usl
        elif lsl <= min_num and min_num <= usl and max_num > usl:
            ticks_l = lsl
            ticks_h = max_num
        elif min_num > usl:
            ticks_l = lsl
            ticks_h = max_num

    if (lsl !='NA' and lsl !='') and (usl =='NA' or usl ==''):
        if min_num < lsl:
            ticks_l = min_num
        else:
            ticks_l = lsl

            

    if (lsl =='NA' or lsl =='') and (usl !='NA' and usl !=''): 
        if max_num<usl:
            ticks_h = usl
        else:
            ticks_h = max_num
        
    range_val = get_limit_range(ticks_l,ticks_h)
    ticks_l,ticks_h = round((ticks_l-range_val/5),2),round((ticks_h+range_val/5),2)
    return ticks_l,ticks_h

def get_limit_range(lsl,usl):
    range_val = 0
    if lsl < 0 and usl <= 0:
        range_val = abs(lsl) - abs(usl)
    elif lsl < 0 and usl >= 0:
        range_val = abs(lsl) + usl
    elif lsl >= 0 and (usl > 0):
        range_val = usl - lsl
    else:
        print('get_limit_range 00000')
    range_val = round(range_val, 5)
    return range_val

def correlation_coefficient_calc(data_l1,data_l2,item_name1,item_name2):

    '''
    item_name1 : string
    item_name2 : string
    data_l2 :[]
    data_l1 :[]
    '''
    if item_name1 == item_name2:# can not be the same name.
       item_name2 = item_name2+'_2'
    data = pd.DataFrame({item_name1:data_l1,
                       item_name2:data_l2})
    pearson = data.corr(method='pearson').values[0].tolist()[1]
    spearman = data.corr(method='spearman').values[0].tolist()[1]
    pearson = round(pearson,5)
    spearman = round(spearman,5)
    # print('pearson:',pearson)
    # print('spearman:',spearman)
    return pearson,spearman

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
    return lsl,usl

def calculate_value(message):
    print("this function is calculate_value......")
    val = r.get(message)   # 注意 等到的都是字符串
    if val:
        val = float(val)*200   # 数学运算
        val = str(val).encode('utf-8')
        return val
    else:
        return b'0'

def run(n):

    while True:
        try:
            print("wait for scatter ...")
            zmqMsg = socket.recv()
            socket.send(b'scatter.png')
            if len(zmqMsg)>0:
                key = zmqMsg.decode('utf-8')
                print(">message from scatter  client:", key)
                table_data = get_redis_data(key)   
                if len(table_data)>0 :
                    scatter_plot(table_data,key)
                else:
                    print("scatter get data error")
                # socket.send(ret.decode('utf-8').encode('ascii'))
            else:
                time.sleep(0.05)
        except Exception as e:
            print('scatter error:',e)

if __name__ == '__main__':
    run(0)
    




