#! /usr/bin/env python3
# --*-- coding: utf-8 ---*---

import sys,os,time,math,re
import datetime


import time
import threading



BASE_DIR=os.path.dirname(os.path.abspath(__file__))
#print('BASE_DIR--->',BASE_DIR)
sys.path.insert(0,BASE_DIR+'/site-packages/')

# print('python import ----> csv')
try:
    import csv
except Exception as e:
    print('e---->',e)




# print('python import ----> pandas')
try:
    import pandas as pd
except Exception as e:
    print('e--->',e)





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
# socket.setsockopt(zmq.LINGER,0)
# socket.bind("tcp://127.0.0.1:3150")


filelogname = ''



def calculate_yield_rate(all_csv_path,yield_rate_csv_path):
    all_csv_path = os.path.join(all_csv_path+ '')
    print('yield_rate path:',all_csv_path)
    tmp_lst = []
    with open(all_csv_path, 'r') as f:
        reader = csv.reader(f)
        i = 1
        for row in reader:
            # print(row[0].lower())
            # if row[0].lower().find('fct') != -1:
            #     # print("FW version---->")
            #     pass
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
    # print("index---->", tmp_lst[0])
    header_list = tmp_lst[1]

    df = pd.DataFrame(tmp_lst[2:], columns=tmp_lst[1])
    print('====ok==')
    print(df['StartTime'])
    try:
        pd.to_datetime(df['StartTime'])
    except Exception as e:
        print('check StartTime,csv format wrong!')
        return e
    header_df =df[0:2]
    # print('header_df before--->', header_df)
    data_df = df[2:]
    # print('data_df before--->', data_df)
 

    # print('csv data row number before remove SN empty--->', len(data_df.values.tolist()))
    data_df=data_df[~data_df['SerialNumber'].isin([''])]#Remove SN Empty
    # print('csv data row number after remove SN empty--->', len(data_df.values.tolist()))
    # print('csv data row number before remove fail--->', len(data_df.values.tolist()))

    total_sn = list((data_df['SerialNumber'].values.tolist()))
    # print('total_sn:',len(total_sn),total_sn)

    pass_df=data_df[data_df['Test Pass/Fail Status'].isin(['PASS'])]
    overall_pass_sn = list(set(list((pass_df['SerialNumber'].values.tolist()))))
    # print('total_pass_sn:',len(total_pass_sn),total_pass_sn)

    fail_df=data_df[data_df['Test Pass/Fail Status'].isin(['FAIL'])]
    overall_fail_sn = list(set(list((fail_df['SerialNumber'].values.tolist()))))
    # print('total_fail_sn:',len(total_fail_sn),total_fail_sn)

    no_retest_pass_sn = [x for x in overall_pass_sn if x not in overall_fail_sn]  #在list1列表中而不在list2列表中
    no_retest_pass_sn = list(set(no_retest_pass_sn))
    print('yield->no_retest_pass_sn',len(no_retest_pass_sn))
    # print('total no_retest_pass_sn:',len(no_retest_pass_sn),no_retest_pass_sn)
    true_fail_sn = [y for y in overall_fail_sn if y not in overall_pass_sn]  #在list2列表中而不在list1列表中
    true_fail_sn = list(set(true_fail_sn))
    # print('total true_fail_sn:',len(true_fail_sn),true_fail_sn)
    total_retest_sn = [z for z in overall_fail_sn if z in overall_pass_sn]  #在list2列表中而不在list1列表中
    total_retest_sn = list(set(total_retest_sn))
    # print('total retest_sn count:',len(total_retest_sn),total_retest_sn)
    total_temp_p_l=[]
    total_temp_p_l_pass=[]
    total_temp_r_l=[]
    for retest_sn in total_retest_sn:
        # print('retest_sn:',retest_sn)
        if retest_sn !='':
            start_time_l = list(data_df.loc[ data_df['SerialNumber'] == retest_sn, 'StartTime'].tolist())
            # print('start_time_l:',start_time_l)
            first_test_time = min(start_time_l)#get_first_time(start_time_l)
            # first_test_time = str(min([datetime.datetime.strptime(i.replace('/','-'),'%Y-%m-%d %H:%M:%S') for i in start_time_l]))
            # first_test_time = first_test_time.replace('-','/')
            # first_test_time = remove_zero(first_test_time)
            # print('first_test_time',first_test_time)
            sn_status = list(data_df.loc[ data_df['StartTime'].isin([first_test_time]) & (data_df['SerialNumber'] == retest_sn), 'Test Pass/Fail Status'].tolist())
            # print('first_test_time,sn_status:',first_test_time,sn_status)
            if sn_status == ['PASS']:
                total_temp_p_l = total_temp_p_l + [retest_sn]
                total_temp_p_l_pass= total_temp_p_l_pass + [retest_sn]
            elif sn_status == ['FAIL']:
                total_temp_r_l = total_temp_r_l + [retest_sn]
                total_temp_p_l = total_temp_p_l + [retest_sn]
            else:
                print('>no status')
        else:
            print('>no sn')

    # print('total_temp_p_l,total_temp_r_l:',len(total_temp_p_l),len(total_temp_r_l))
    total_count = len(no_retest_pass_sn+total_temp_p_l+true_fail_sn)
    # print('yield->total_temp_p_l',len(total_temp_p_l_pass),len(total_temp_p_l),len(true_fail_sn),total_count,len(total_retest_sn))
    total_fail_sn = true_fail_sn
    fail_count = len(total_fail_sn)
    no_retest_pass_count = len(no_retest_pass_sn)
    pass_count = len(no_retest_pass_sn+total_retest_sn)
    if total_count != 0:
        yield_rate = (pass_count)/ total_count*100.0
        fail_rate = (fail_count/ total_count)*100.0
        first_pass_yield_rate = (no_retest_pass_count/ total_count)*100.0
        retest_rate =len(list(set(total_temp_r_l)))/total_count*100.0
    else:
        yield_rate = 0
        fail_rate = 0
        first_pass_yield_rate = 0
        retest_rate = 0

    # print('total_retest_sn',total_retest_sn)
    # print('no_retest_pass_count',no_retest_pass_count)
    # print('yield_rate:',yield_rate)
    # print('first_pass_yield:',first_pass_yield_rate)
    # print('fail_rate:',fail_rate)
    # print('retest_rate:',retest_rate)
    # print('first_pass_yield:',first_pass_yield_rate)

    test_count = pass_count  + fail_count
    retest_count = len(list(set(total_temp_r_l)))
    retest_rate = round((retest_count)/(pass_count  + fail_count)*100.0,2)
    yield_percentage = round(pass_count/test_count*100.0,2)
    fail_percentage = round(fail_count/test_count*100.0,2)

    # print("all station test count:(no duplication sn)",test_count)
    # print("all station Fail:",fail_count)
    # print("all station Pass:",pass_count)
    # print('all station retest count:',retest_count)
    # print('all station retest rate:',retest_rate)
    # print('all station yield percentage:',yield_percentage)
    
    with open(yield_rate_csv_path,'w') as f:
        writer = csv.writer(f)
        writer.writerow(['Station ID','Input (TOTAL)',' FAIL Qty','PASS Qty','RETEST Qty','Retest Rate (%)','FPY (%)','FAIL Rate (%)'])
        writer.writerow(['All Station',test_count,fail_count,pass_count,retest_count,str(retest_rate)+'%',str(yield_percentage)+'%',str(fail_percentage)+'%'])


    station_id_l = list(set(data_df['Station ID'].values.tolist()))
    # print('station_id_l:',len(station_id_l),station_id_l)
    for station_id in station_id_l:
        total_sn_by_station_id = list((data_df.loc[(data_df['Station ID'] == station_id), 'SerialNumber'].tolist()))
        total_sn_by_station_id = list(set(total_sn_by_station_id))
        # print(station_id+' total_sn_by_station_id:',len(total_sn_by_station_id),total_sn_by_station_id)

        pass_sn_by_station_id = list((data_df.loc[(data_df['Station ID'] == station_id) & (data_df['Test Pass/Fail Status'].isin(['PASS'])), 'SerialNumber'].tolist()))
        pass_sn_by_station_id = list(set(pass_sn_by_station_id))
        # print('pass_sn_by_station_id:',len(pass_sn_by_station_id),pass_sn_by_station_id)

        fail_sn_by_station_id = list((data_df.loc[(data_df['Station ID'] == station_id) & (data_df['Test Pass/Fail Status'].isin(['FAIL'])), 'SerialNumber'].tolist()))
        fail_sn_by_station_id = list(set(fail_sn_by_station_id))
        # print(station_id,'fail_sn_by_station_id:',len(fail_sn_by_station_id),fail_sn_by_station_id)

        no_retest_pass_sn_by_station_id = [x for x in pass_sn_by_station_id if x not in overall_fail_sn]  #在list1列表中而不在list2列表中
        no_retest_pass_sn_by_station_id = list(set(no_retest_pass_sn_by_station_id))
        # print(station_id,'no_retest_pass_sn_by_station_id:',len(no_retest_pass_sn_by_station_id),no_retest_pass_sn_by_station_id)
        true_fail_sn_by_station_id = [y for y in fail_sn_by_station_id if y not in overall_pass_sn]  #在list2列表中而不在list1列表中
        true_fail_sn_by_station_id = list(set(true_fail_sn_by_station_id))
        # print(station_id,'true_fail_sn_by_station_id:',len(true_fail_sn_by_station_id),true_fail_sn_by_station_id)
        retest_sn_by_station_id = [z for z in fail_sn_by_station_id if z in overall_pass_sn]  
        retest_sn_by_station_id = list(set(retest_sn_by_station_id))
        # print(station_id,'retest_sn_by_station_id:',len(retest_sn_by_station_id),retest_sn_by_station_id)

        retest_pass_sn_by_station_id = [w for w in pass_sn_by_station_id if w in overall_fail_sn]  
        retest_pass_sn_by_station_id = list(set(retest_pass_sn_by_station_id))
        # print(station_id,'retest_pass_sn_by_station_id:',len(retest_pass_sn_by_station_id),retest_pass_sn_by_station_id)

        temp_p_l1=[]
        temp_r_l1=[]
        for retest_sn in retest_pass_sn_by_station_id:
            if retest_sn != '':
                start_time_l = list(data_df.loc[ data_df['SerialNumber'] == retest_sn, 'StartTime'].tolist())
                # print('start_time_l:',start_time_l)
                first_test_time = min(start_time_l)

                # print('first_test_time',first_test_time)                
                sn_status = list(data_df.loc[ data_df['StartTime'].isin([first_test_time]) & (data_df['SerialNumber'] == retest_sn), 'Test Pass/Fail Status'].tolist())
                retest_station_id = list(data_df.loc[ data_df['StartTime'].isin([first_test_time]) & (data_df['SerialNumber'] == retest_sn), 'Station ID'].tolist())
                
                # print('first_test_time,sn_status,retest_station_id:',first_test_time,sn_status,retest_station_id,station_id,retest_station_id[0])
                if sn_status == ['PASS'] and  station_id == retest_station_id[0]:
                    temp_p_l1 = temp_p_l1 + [retest_sn]
                elif sn_status == ['FAIL'] and station_id == retest_station_id[0]:
                    temp_r_l1 = temp_r_l1 + [retest_sn]
                    temp_p_l1 = temp_p_l1 + [retest_sn]


        # print('\n',station_id,'temp_p_l1,temp_r_l1:',len(temp_p_l1),len(temp_r_l1),temp_p_l1,temp_r_l1)

        temp_p_l=[]
        temp_r_l=[]
        for retest_sn in retest_sn_by_station_id:
            if retest_sn != '':
                start_time_l = list(data_df.loc[ data_df['SerialNumber'] == retest_sn, 'StartTime'].tolist())
                # print('start_time_l:',start_time_l)
                first_test_time = min(start_time_l)
           
                # print('first_test_time',first_test_time)                
                sn_status = list(data_df.loc[ data_df['StartTime'].isin([first_test_time]) & (data_df['SerialNumber'] == retest_sn), 'Test Pass/Fail Status'].tolist())
                retest_station_id = list(data_df.loc[ data_df['StartTime'].isin([first_test_time]) & (data_df['SerialNumber'] == retest_sn), 'Station ID'].tolist())
                
                # print('first_test_time,sn_status,retest_station_id:',first_test_time,sn_status,retest_station_id,station_id,retest_station_id[0])
                if sn_status == ['PASS'] and  station_id == retest_station_id[0]:
                    temp_p_l = temp_p_l + [retest_sn]
                elif sn_status == ['FAIL'] and station_id == retest_station_id[0]:
                    temp_r_l = temp_r_l + [retest_sn]
                    temp_p_l = temp_p_l + [retest_sn]


        # print('\n',station_id,'temp_p_l,temp_r_l:',len(temp_p_l),len(temp_r_l),temp_p_l,temp_r_l)



        temp_true_fail_l=[]
        for temp_true_fail_sn in true_fail_sn_by_station_id:
            start_time_l = list(data_df.loc[ data_df['SerialNumber'] == temp_true_fail_sn, 'StartTime'].tolist())
            first_test_time = min(start_time_l)

            sn_station_id = list(data_df.loc[ data_df['StartTime'].isin([first_test_time]) & (data_df['SerialNumber'] == temp_true_fail_sn), 'Station ID'].tolist())
            if station_id == sn_station_id[0]:
                temp_true_fail_l = temp_true_fail_l + [temp_true_fail_sn]            
        fail_count_by_station_id = len(temp_true_fail_l)

        temp_no_retest_p_sn_l = []
        for no_retest_p_sn in no_retest_pass_sn_by_station_id:
            start_time_l = list(data_df.loc[ data_df['SerialNumber'] == no_retest_p_sn, 'StartTime'].tolist())
            first_test_time = min(start_time_l)
            sn_station_id = list(data_df.loc[ data_df['StartTime'].isin([first_test_time]) & (data_df['SerialNumber'] == no_retest_p_sn), 'Station ID'].tolist())
            # print('sn_station_id:',sn_station_id)
            if station_id == sn_station_id[0]:
                temp_no_retest_p_sn_l = temp_no_retest_p_sn_l + [no_retest_p_sn]



        # print(station_id,'temp_no_retest_p_sn_l:',len(temp_no_retest_p_sn_l),temp_no_retest_p_sn_l)
        pass_count_by_station_id = len(list(set(temp_no_retest_p_sn_l + temp_p_l+temp_p_l1)))
        total_count_by_station_id = fail_count_by_station_id+pass_count_by_station_id
        no_retest_pass_count_by_station_id = len(temp_no_retest_p_sn_l)
        retest_count_by_station_id = len(list(set(temp_r_l+temp_r_l1)))
        if total_count_by_station_id != 0:
            yield_rate_by_station_id = round(pass_count_by_station_id/total_count_by_station_id*100.0,2)
            fail_rate_by_station_id = round((fail_count_by_station_id/ total_count_by_station_id)*100.0,2)
            first_pass_yield_rate_by_station_id = round((no_retest_pass_count_by_station_id/ total_count_by_station_id)*100.0,2)
            retest_rate_by_station_id = round((retest_count_by_station_id)/total_count_by_station_id*100.0,2)
        else:
            yield_rate_by_station_id = 0
            fail_rate_by_station_id  = 0
            first_pass_yield_rate_by_station_id = 0
            retest_rate_by_station_id = 0
            
        # print('\n'+station_id+':')
        # print("test count:(no duplication sn)",total_count_by_station_id)
        # print("Fail count:",fail_count_by_station_id)
        # print("Pass count:",pass_count_by_station_id)
        # print('retest count:',retest_count_by_station_id)
        # print('yield_rate:',yield_rate_by_station_id)
        # print('first_pass_yield:',first_pass_yield_rate_by_station_id)
        # print('fail_rate:',fail_rate_by_station_id)
        # print('retest_rate:',retest_rate_by_station_id)
        with open(yield_rate_csv_path,'a') as f1:
            writer_by_station_id = csv.writer(f1)
            writer_by_station_id.writerow([station_id,total_count_by_station_id,fail_count_by_station_id,pass_count_by_station_id,retest_count_by_station_id,str(retest_rate_by_station_id)+'%',str(yield_rate_by_station_id)+'%',str(fail_rate_by_station_id)+'%'])

    print('---finished----')


            

if __name__ == '__main__':
    calculate_yield_rate('/private/tmp/CPK_Log/temp/.custom2insight.csv','/tmp/CPK_Log/temp/211.csv')
    # run(0)
    # t1 = threading.Thread(target=run, args=("<<correlation>>",))
    # t1.start()

    
