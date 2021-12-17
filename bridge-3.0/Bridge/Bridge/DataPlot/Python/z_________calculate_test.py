#! /usr/bin/env python3
# --*-- coding: utf-8 ---*---

import sys,os,time,math,re
import datetime


import time
import threading

start_time = datetime.datetime.now()  #
show_log_flag = True



BASE_DIR=os.path.dirname(os.path.abspath(__file__))
#print('BASE_DIR--->',BASE_DIR)
sys.path.insert(0,BASE_DIR+'/site-packages/')

# print('python import ----> csv')
try:
    import csv
except Exception as e:
    print('e---->',e)

# print('python import ---->matplotlib')
try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
except Exception as e:
    print('e---->',e)

# print('python import ----> matplotlib.colors')
try:
    import matplotlib.colors as colors
except Exception as e:
    print('e---->',e)

# print('python import ----> FontProperties')
try:
    from matplotlib.font_manager import FontProperties
except Exception as e:
    print('e---->',e)


# print('python import ----> numpy')
try:
    import numpy as np
    np.set_printoptions(suppress=True)
except Exception as e:
    print('e--->',e)

# print('python import ----> pandas')
try:
    import pandas as pd
except Exception as e:
    print('e--->',e)

# print('python import ----> openpyxl')
try:
    import openpyxl
except Exception as e:
    print('import openpyxl error:',e)
# print('python import ----> xlsxwriter')
try:
    import xlsxwriter
except Exception as e:
    print('import xlsxwriter error:',e)

# print('python import ----> diptest')
try:
    import diptest
except Exception as e:
    print('import diptest error:',e)

# print('python import ----> scipy')
# try:
#     from scipy import stats
# except Exception as e:
#     print('import scipy error:',e)

try:
    import zmq
except Exception as e:
    print('import zmq error:',e)
# print('python import ----> zmg')

try:
    import redis
except Exception as e:
    print('import redis error:',e)
# print('python import ----> redis')

print(sys.getdefaultencoding())



# redisClient = redis.Redis(host='localhost', port=6379, db=0)
# context = zmq.Context()
# socket = context.socket(zmq.REP)
# socket.bind("tcp://127.0.0.1:3120")


def calulate_param(header_list,df,csv_path,cpk_hthl):

    data = [('item_name','BC','P_Val','a_Q','a_irr','3CV','Orig_CPK','BMC'),]
    f = open(csv_path,'w')
    writer = csv.writer(f)

    writer.writerow(('item_name','BC','P_Val','a_Q','a_irr','3CV','Orig_CPK','BMC'))
    column_list = []
    n=0
    for item_name in header_list:
        column_list = df[item_name].values.tolist()

        usl = column_list[0]
        lsl = column_list[1]


        need_calculate = need_calculate_param(item_name,column_list)
        print('need_calculate_param:',item_name,need_calculate,len(column_list))
        column_num_list = []
        BMC = ''
        if need_calculate == 'need_calculate_param':
            column_list = test_value_to_numeric(column_list[:])

            try:
                usl = column_list[0]
                lsl = column_list[1]
            except Exception as e:
                usl = 'NA'
                lsl = 'NA'

            bc,p_val,a_Q,a_irr,three_CV = get_coefficients(column_list[2:])

            mean, max_num, min_num, stdev, x1, y1, cpu, cpl, Orig_CPK_value = cpk_calc(column_list[2:], lsl, usl)

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
            if Orig_CPK_value: 
                if is_number(str(Orig_CPK_value)):
                    if Orig_CPK_value > cpk_hthl:
                        BMC = ''
                    Orig_CPK_value = round(Orig_CPK_value,3)

                value = (item_name,bc,p_val,a_Q,a_irr,three_CV,Orig_CPK_value,BMC)
                writer.writerow(value)
            else:
                value = (item_name,bc,p_val,a_Q,a_irr,three_CV,'--',BMC)
                writer.writerow(value)

        else:
            value = (item_name,'','','','','','--','')
            writer.writerow(value)

        n=n+1

    f.close()


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
    # print('cpu ---->',cpu)
    # print('cpl ---->',cpl)

    # 得出cpk
    cpk = min(cpu, cpl)
    mean = round(mean,3)
    return (mean,max_num,min_num,stdev,x1,y1,cpu,cpl,cpk)

def need_calculate_param(test_item_name,column_list):

    # column_list = df[test_item_name].tolist()
    # print('valid_column item_name-->',test_item_name)
    # print('valid_column--->',len(column_list),column_list)

    # print('column_value_list--->',column_list)
    # if test_item_name.lower().find('fixture vendor_id') == -1 and test_item_name.lower().find('fixture channel id') and test_item_name.lower().find('unit number')== -1 and test_item_name.lower().find('head id')== -1:
    #     pass
    # else:
    #     return 'not_calculate_param state1'

    if len(column_list)< 5:#or  column_list[0] == column_list[1] and  column_list[0] !='NA'
        # print('====>',column_list[0],column_list[1])
        return "not_calculate_param state2"
    else:
        
        j=0
        for i in range(2,len(column_list),1):
            if is_number(column_list[i]):
                j=j+1
                if j>3 and len(set(column_list))>=1:#
                    # print('need_cpk')
                    return "need_calculate_param"
 
        return "not_calculate_param state3"

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



def is_number(num):
    is_float = True
    try:
        value = float(num)
    except Exception as e:
        is_float = False

    return is_float


def valid_column(test_item_name,column_list):

    # column_list = df[test_item_name].tolist()
    # print('valid_column item_name-->',test_item_name)
    # print('valid_column--->',len(column_list),column_list)

    # print('column_value_list--->',column_list)
    if test_item_name.lower().find('_cb_count') == -1 and test_item_name.lower().find('fixture channel id') == -1 and test_item_name.lower().find('ss1_num_tri') == -1 and test_item_name.lower().find('fixture vendor_id') == -1:
        pass
    else:
        return 'not_cpk state1'
    if column_list[0] == '0' and column_list[1] == '0' or column_list[0] == '1' and column_list[
        1] == '1' or  column_list[0] == column_list[1] and  column_list[0] !='NA' or len(column_list)< 5:
        # print('====>',column_list[0],column_list[1])
        return "not_cpk state2"
    else:
        # pattern = re.compile(r'^[+-]?[0-9]*\.?[0-9]+$')
        # print('valid_column len----->',test_item_name,len(column_list))
        # print('v====>',column_list[0],column_list[1],column_list,len(column_list))
        j=0
        for i in range(2,len(column_list),1):
            # print(str(i),'valid_column----->',test_item_name,pattern.match(column_list[i]))
            if is_number(column_list[i]):
                j=j+1
                # print(str(j)+',len(set(column_list))-->',j,len(set(column_list)))
                if j>3 and len(set(column_list))>=1:
                    # print('need_cpk')
                    return "need_cpk"
 
        return "not_cpk state3"

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
            # print('three_CV:',three_CV)
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
        return str(round(bc,6)),str(p_val),str(round(a_Q,6)),str(round(a_irr,6)),str(round(three_CV,6))


def open_all_csv(event,all_csv_path,data_select,remove_fail):
    all_csv_path = os.path.join(all_csv_path+ '')
    tmp_lst = []
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
    header_list = tmp_lst[1][param_item_start_index:]

    df = pd.DataFrame(tmp_lst[2:], columns=tmp_lst[1])
    header_df =df[0:2]
    data_df = df[2:]

    # data_df=data_df[~data_df['SerialNumber'].isin([''])] #Remove SN Empty
    if remove_fail== 'yes':
        data_df=data_df[data_df['Test Pass/Fail Status'].isin(['PASS'])]

    project_code,build_stage,station_name = '','',''
    start_time_first = ''
    start_time_last  = ''

    df = header_df.append(data_df)

    return header_list,df,project_code,build_stage,station_name,start_time_first,start_time_last,param_item_start_index


def cpk_technology_show(csv_pah,output_csv):
    df = pd.read_csv(csv_pah)
    cpk_values = df['Orig_CPK']
    item_names = df['item_name']
    csv_path2 = '/tmp/CPK_Log/temp/.item_cpk_add_group.csv'
    f_csv = open(csv_path2,'w',encoding='utf-8')
    csv_writer = csv.writer(f_csv)
    csv_writer.writerow(['item_name','Orig_CPK','Technology_Tags'])

    n_index = 0
    for cpk_value in cpk_values:
        if cpk_value!='--':
            item_name = item_names[n_index]
            item_group = item_name.split(' ')[0]
            csv_writer.writerow([str(item_name),str(cpk_value),str(item_group)])
        n_index = n_index +1
    f_csv.close()


    f_csv = open(output_csv,'w',encoding='utf-8')
    csv_writer = csv.writer(f_csv)
    csv_writer.writerow(['Technology Tag','Min Cpk','Max Cpk','Min Cpk Item Name','Max Cpk Item Name'])

    df = pd.read_csv(csv_path2)
    for groupName, groupDf in df.groupby('Technology_Tags'):
        # print('**********************')
        l_cpk = []
        l_name = []
        for index,row in groupDf.iterrows():
            l_cpk.append(round(row['Orig_CPK'],3))
            l_name.append(row['item_name'])
        cpk_max = max(l_cpk)
        cpk_max_index = l_cpk.index(cpk_max)
        cpk_min = min(l_cpk)
        cpk_min_index = l_cpk.index(cpk_min)
        csv_writer.writerow([str(groupName),str(cpk_min),str(cpk_max),str(l_name[cpk_min_index]),str(l_name[cpk_max_index])])
        # if cpk_max == cpk_min:
        # else:
            # print(l_name[cpk_min_index],cpk_min)
            # csv_writer.writerow([str(groupName),str(l_name[cpk_min_index]),str(cpk_min),'--'])
            # print(l_name[cpk_max_index],cpk_max)
            # csv_writer.writerow([str(groupName),str(l_name[cpk_max_index]),'--',str(cpk_max)])

    f_csv.close()

def correlation(message):
    print("this function is generate correlation plot......")
    val = redisClient.get(message)
    # time.sleep(5)  #测试python 执行时间 5s
    if val:
        return val
    else:
        return b'None'
   

def run(n):
    while True:
        try:
            print("wait for calculate client ...")
            zmqMsg = socket.recv()
            socket.send(b'calculate_sendback')
            if len(zmqMsg)>0:
                keyMsg = zmqMsg.decode('utf-8')
                print("message from calculate client:", keyMsg)
                msg =keyMsg.split("$$")
                if len(msg)>5:
                    if msg[0] == 'calculate-param':
                        data_select = 'all'
                        remove_fail = 'yes'
                        all_csv_path = msg[1]
                        csv_path = msg[2]
                        filelogname = msg[3]
                        cpk_lthl = float(msg[4])
                        cpk_hthl = float(msg[5])

                        time1 = time.time()
                        header_list,df,project_code,build_stage,station_name,start_time_first,start_time_last,param_item_start_index =  open_all_csv('calculate-param',all_csv_path,data_select,remove_fail)
                        time2 = time.time()
                        print('open_all_csv function time :',time2-time1)

                        calulate_param(header_list,df,csv_path,cpk_hthl)
                        print('>calulate_param cpk done')
                        time3 = time.time()
                        print('calulate_param function time :',time3-time2)

                        cpk_technology_show(csv_path,'/tmp/CPK_Log/retest/cpk_min_max.csv')
                        print('>cpk_technology_show done')
                        time4 = time.time()
                        print('cpk_technology_show function time :',time4-time3)
                        print('time:',time1,time2,time3,time4)
                        with open(filelogname, 'w') as file_object:
                            file_object.write("PASS,calculate is finished")
                        with open('/tmp/CPK_Log/retest/.retest_plot.txt', 'w') as file_object:
                            file_object.write("Finished,cpk_min_max is finished")
                            print('>calulate_param exit')
                            return


            else:
                time.sleep(0.05)
        except Exception as e:
            print('calculate_test error:',e)

if __name__ == '__main__':
    # run(0)

    all_csv_path = '/tmp/test/.custom2insight1.csv'
    data_select = 'all'
    remove_fail = 'yes'
    header_list,df,project_code,build_stage,station_name,start_time_first,start_time_last,param_item_start_index =  open_all_csv('calculate-param',all_csv_path,data_select,remove_fail)

    print('--*******-',param_item_start_index)
    cpk_lthl = 1.5
    cpk_hthl = 10.0
    csv_path = '/tmp/test/custom22222.csv'
    calulate_param(header_list,df,csv_path,cpk_hthl)



    
