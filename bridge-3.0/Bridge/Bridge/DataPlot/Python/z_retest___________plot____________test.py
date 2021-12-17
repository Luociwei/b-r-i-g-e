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

# station_id_key = ''
# slot_id_key = ''

# redisClient = redis.Redis(host='localhost', port=6379, db=0)
# context = zmq.Context()
# socket = context.socket(zmq.REP)
# socket.setsockopt(zmq.LINGER,0)
# socket.bind("tcp://127.0.0.1:3191")



def clear_files(path):  #  '/tmp/CPK_Log/fail_plot/'
    for root, dirs, files in os.walk(path):
        for file in files:
            os.remove(path + '/' + file)

def my_mkdir(path):
    isExists=os.path.exists(path)
    if not isExists:
        os.makedirs(path) 
        return True
    else:
        return False

def get_csv_file_name(file_dir):
    csv_file_l = []
    files = os.listdir(file_dir)
    files.sort(key=lambda x: str(x.split('.')[0]))
    for file in files:
        if os.path.splitext(file)[1] == '.csv':
            csv_file_l.append(os.path.splitext(file)[0])
    return csv_file_l

def checkItemName(string, minlength, maxlength):
    lines = textwrap.wrap(string.replace('_',' '), maxlength)
    newlines = list(lines)
    index = 0
    for l in lines:
        if len(l) < minlength and index > 0:
            prelist = lines[index-1].split(" ")
            postlist = l.split(" ")
            lastword = prelist[-1]
            prelist.remove(lastword)
            postlist.insert(0,lastword)

            if len( " ".join(prelist) ) >= minlength:
                newlines[index-1] = " ".join(prelist)
                newlines[index] = " ".join(postlist)
        
        index += 1

    wraptext = "\n".join(newlines)
    return wraptext

def randomcolor():
    colorArr = ['1','2','3','4','5','6','7','8','9','A','B','C','D','E','F']
    color = ""
    for i in range(6):
        color += colorArr[random.randint(0,14)]
    return "#"+color

def summary_retest_csv(csv_data_path,header_item_path,csv_path_output):
    
    with open(header_item_path,'r') as csvfile:
        reader = csv.reader(csvfile)
        header_rows = [row for row in reader]

    data1 = pd.read_csv(csv_data_path)
    data0 = pd.read_csv('/tmp/CPK_Log/retest/..total_count_by_date_product.csv')
    df0 = pd.DataFrame(data0)
    df = pd.DataFrame(data1)
    if len(data1) == 0:
        f_csv = open(csv_path_output,'w',encoding='utf-8')
        csv_writer = csv.writer(f_csv)
        header_list = header_rows[0]
        date_total_list = header_rows[5]

        data_group_name = []
        data_group_name.append('Date')
        for groupName in header_list:
            data_group_name.append(groupName)
            data_group_name.append(groupName+'_#TOTAL')
            data_group_name.append(groupName+'_#RATE')

        data_group_name.append('ALL')
        data_group_name.append('ALL_#TOTAL')
        data_group_name.append('ALL_#RATE')
        data_group_name.append('OVERALL_RETEST_RATE_#RATE')
        csv_writer.writerow(data_group_name)


        for date_time in date_total_list:
            data_list_1 = []
            data_list_1.append(str(date_time))
            all_count = 0
            for groupName in header_list:

                t_flag = False
                try:
                    tt_list = list(df0.loc[(df0['Date Product'] == str(date_time) + ' ' + str(groupName)), 'TOTAL'].tolist())
                    t_flag = True
                    if len(tt_list) == 0:
                        tt_list.append('0')
                except Exception as e:
                    # print('error:',str(e))
                    t_flag = False

                if t_flag:
                    data_list_1.append('0')
                    # print('---111>>>>>',str(date_time) + ' ' + str(groupName))
                    data_list_1.append(str(tt_list[0]))
                    data_list_1.append('0')
                    all_count = all_count + int(tt_list[0])

            data_list_1.append('0')
            data_list_1.append(str(all_count))
            data_list_1.append('0')
            data_list_1.append('0')  # overall retest rate
            csv_writer.writerow(data_list_1)


        f_csv.close()
        return 

    
    #-------if have data---------
    
    x_datetime = []
    for x_date in df0['Date']:
        date_time = pd.to_datetime(x_date).strftime("%Y/%m/%d")
        x_datetime.append(date_time)
    x_datetime = sorted(list(set(x_datetime)))
    # print(x_datetime)
    data_group_name = []
    data_group_name.append('Date')
    dict_d = {}

    for groupName, groupDf in df.groupby(by='Product'):
        # print('**********************************',groupName)
        if len(groupName)>0:
            
            data_group_name.append(groupName)
            data_group_name.append(groupName+'_#TOTAL')
            data_group_name.append(groupName+'_#RATE')
            l_retest = []
            for x_time in x_datetime:
                timeStart = pd.to_datetime(x_time,format = "%Y/%m/%d")
                timeEnd = timeStart + timedelta(days=0,hours= 23,minutes = 59,seconds = 59)
                n_retest_count = 0
                for index,row in groupDf.iterrows():
                    lineDate = pd.to_datetime(row['Date'])
                    if lineDate >=timeStart and lineDate<=timeEnd:
                        n_retest_count = n_retest_count + 1

                tt_list = list(df0.loc[(df0['Date Product'] == str(x_time) + ' ' + str(groupName)), 'TOTAL'].tolist())
                try:
                    if len(tt_list) == 0:
                        tt_list.append("0")
                        list_rate_percent = '0'
                    else:
                        x_percent = round(int(n_retest_count)/int(tt_list[0])*100,3)
                        list_rate_percent = str(x_percent)
                except Exception as e:
                    print('summary_retest_csv error',str(e))
                    tt_list.append('0')
                    list_rate_percent = '0'

                l_retest.append(str(x_time)+','+str(n_retest_count)+','+str(tt_list[0])+','+str(list_rate_percent))
            dict_d[groupName] = l_retest

    for groupName in header_rows[0]:  # only pass data,no retest data also need to add
        if groupName not in data_group_name:
            data_group_name.append(groupName)
            data_group_name.append(groupName+'_#TOTAL')
            data_group_name.append(groupName+'_#RATE')
            l_retest = []
            for x_time in x_datetime:
                tt_list = list(df0.loc[(df0['Date Product'] == str(x_time) + ' ' + str(groupName)), 'TOTAL'].tolist())
                try:
                    xx_tmp = tt_list[0]
                except Exception as e:
                    # print('for tt_list[0]:',e)
                    xx_tmp = 0

                l_retest.append(str(x_time)+',0,'+str(xx_tmp)+',0')
            dict_d[groupName] = l_retest

    n_count = 0
    for name in data_group_name:
        if (not name == 'Date') and ('_#TOTAL' not in name) and ('_#RATE' not in name):
            if n_count == 0:
                f_csv = open(csv_path_output,'w',encoding='utf-8')
                csv_writer = csv.writer(f_csv)
                csv_writer.writerow(data_group_name)

                for row_name in dict_d[name]:
                    date_row = row_name.split(',')
                    csv_writer.writerow([date_row[0],date_row[1],date_row[2],date_row[3]])
                f_csv.close()
            else:
                with open(csv_path_output, 'r') as f:
                    reader = csv.reader(f)
                    store_d = []
                    for row in reader:
                        store_d.append(row)
                
                f_csv = open(csv_path_output,'w',encoding='utf-8')
                csv_writer = csv.writer(f_csv)
                csv_writer.writerow(data_group_name)

                n_index = 1
                for row_name in dict_d[name]:
                    date_row = row_name.split(',')
                    row_line = store_d[n_index]
                    row_line.insert(len(row_line),date_row[1])
                    row_line.insert(len(row_line),date_row[2])
                    row_line.insert(len(row_line),date_row[3])
                    csv_writer.writerow(row_line)

                    n_index = n_index +1
                f_csv.close()

            n_count = n_count +1


    n_total_all_list = []
    n_total_retest_all_list = []
    for x_time in x_datetime:
        timeStart = pd.to_datetime(x_time,format = "%Y/%m/%d")
        timeEnd = timeStart + timedelta(days=0,hours= 23,minutes = 59,seconds = 59)

        n_total_all = 0
        for groupName0, groupDf0 in df0.groupby(by='Date Product'):
            if x_time in groupName0:
                n_total_all = int(groupDf0['TOTAL']) + n_total_all
        n_total_all_list.append(n_total_all)

        n_total_retest_all = 0
        for index,row in df.iterrows():
            lineDate = pd.to_datetime(row['Date'])
            if lineDate >=timeStart and lineDate <= timeEnd:
                n_total_retest_all = n_total_retest_all+1

        n_total_retest_all_list.append(n_total_retest_all)

    with open(csv_path_output, 'r') as f:
        reader = csv.reader(f)
        store_d = []
        for row in reader:
            store_d.append(row)
    f_csv = open(csv_path_output,'w',encoding='utf-8')
    csv_writer = csv.writer(f_csv)


    pie_retest_csv_path = '/tmp/CPK_Log/retest/.pie_retest.csv'
    df_count = pd.read_csv(pie_retest_csv_path)
    if len(df_count['TOTAL']) == 0:
        input_total_count = 0
    else:
        input_total_count= max(df_count['TOTAL'])

    if len(df_count['Retest PASS']) == 0:
        retest_pass_total = 0
    else:
        retest_pass_total= max(df_count['Retest PASS'])

    if input_total_count == 0 or retest_pass_total == 0:
        percantage_retest = 0.0
    else:
        percantage_retest = round(float(retest_pass_total)/float(input_total_count)*100,3)

    n_index = 0
    for row_d in store_d:
        if n_index == 0:
            row_line = store_d[n_index]
            row_line.insert(len(row_line),'ALL')
            row_line.insert(len(row_line),'ALL_#TOTAL')
            row_line.insert(len(row_line),'ALL_#RATE')
            row_line.insert(len(row_line),'OVERALL_RETEST_RATE_#RATE')
            csv_writer.writerow(row_line)
        else:
            row_line = store_d[n_index]

            try:
                total_num = n_total_all_list[n_index-1]
            except Exception as e:
                print('.error get retest',e)
                total_num = 0

            try:
                retest_num = n_total_retest_all_list[n_index-1]
            except Exception as e:
                print('.error get retest',e)
                retest_num = 0

            if total_num == 0:
                rate_percentage = 0
            else:
                rate_percentage = round(float(retest_num)/float(total_num)*100,3)
            
            row_line.insert(len(row_line),str(retest_num))
            row_line.insert(len(row_line),str(total_num))
            row_line.insert(len(row_line),str(rate_percentage))
            row_line.insert(len(row_line),str(percantage_retest))  # OVERALL_RETEST_RATE_#RATE --->>test 9.05
            csv_writer.writerow(row_line)

        n_index = n_index+1
    f_csv.close()


def retest_vs_Version_csv(csv_data_path,header_item_path,keyword,csv_path_output):

    data0 = pd.read_csv('/tmp/CPK_Log/retest/..total_count_by_version.csv')
    df0 = pd.DataFrame(data0)

    data1 = pd.read_csv(csv_data_path)
    df = pd.DataFrame(data1)

    with open(header_item_path,'r') as csvfile:
        reader = csv.reader(csvfile)
        header_rows = [row for row in reader]

    print('>retest_vs_Version_csv start')
    list_version_id = []
    list_retest_count = []
    list_total_count = []
    list_rate_percent = []
    for groupName, groupDf in df.groupby(by=keyword): #'Station ID'
        n_count = 0
        for index,row in groupDf.iterrows():
            n_count = n_count + 1

        list_version_id.append(groupName)
        list_retest_count.append(n_count)
        tt_list = list(df0.loc[(df0['Version'] == groupName), 'TOTAL'].tolist())
        try:
            xx_tmp = tt_list[0]
        except Exception as e:
            # print('for tt_list[0]:',e)
            xx_tmp = 0
        list_total_count.append(str(xx_tmp))

        try:
            if int(xx_tmp) == 0:
                list_rate_percent.append('0')
            else:
                x_percent = round(int(n_count)/int(xx_tmp)*100,3)
                list_rate_percent.append(str(x_percent))
        except Exception as e:
            print('error convert int :',str(e))
            list_rate_percent.append('0')

    print('>retest_vs_Version_csv done')
    f_csv = open(csv_path_output,'w',encoding='utf-8')
    csv_writer = csv.writer(f_csv)
    csv_writer.writerow(['Index','Retest_Count','TOTAL','RATE','OVERALL_RETEST_RATE'])


    pie_retest_csv_path = '/tmp/CPK_Log/retest/.pie_retest.csv'
    df_count = pd.read_csv(pie_retest_csv_path)
    if len(df_count['TOTAL']) == 0:
        input_total_count = 0
    else:
        input_total_count= max(df_count['TOTAL'])

    if len(df_count['Retest PASS']) == 0:
        retest_pass_total = 0
    else:
        retest_pass_total= max(df_count['Retest PASS'])
    if input_total_count == 0 or retest_pass_total == 0:
        percantage_retest = 0
    else:
        percantage_retest = round(float(retest_pass_total)/float(input_total_count)*100,3)

    # print('percantage_retest:',percantage_retest)


    n_index = 0
    for x_row in list_version_id:
        version_name = str(list_version_id[n_index])
        if version_name == '':
            version_name = 'NA'
        csv_writer.writerow([version_name,str(list_retest_count[n_index]),str(list_total_count[n_index]),str(list_rate_percent[n_index]),str(percantage_retest)])
        n_index = n_index+1

    diff_list = find_diff_intwo_list(list_version_id,header_rows[4])
    for diff_value in diff_list:
        tt_list = list(df0.loc[(df0['Version'] == diff_value), 'TOTAL'].tolist())
        try:
            xx_tmp = tt_list[0]
        except Exception as e:
            # print('for tt_list[0]:',e)
            xx_tmp = 0
        version_name = str(diff_value)
        if version_name == '':
            version_name = 'NA'
        csv_writer.writerow([version_name,'0',str(xx_tmp),'0',str(percantage_retest)])

    f_csv.close()



def cut_station_name(staion_name):
    station_name_list = staion_name.split('-')
    if len(station_name_list)>2:
        return ''.join(station_name_list[2:])
    if len(station_name_list)>1:
        return ''.join(station_name_list[1:])
    return ''.join(station_name_list[0])



# for station id - slot id ,version
def retest_vs_plot(csv_path,title_name,pie_retest_csv_path,pic_path,descend = False):

    isExists=os.path.exists(csv_path)
    if not isExists:
        plt.gca().spines["top"].set_alpha(.0)
        plt.gca().spines["bottom"].set_alpha(.5)
        plt.gca().spines["right"].set_alpha(.0)
        plt.gca().spines["left"].set_alpha(.5)
        plt.tight_layout() 
        plt.savefig(pic_path, dpi=200)
        return 

    data1= pd.read_csv(csv_path)
    df = pd.DataFrame(data1)
    if descend == True:
        df = df.sort_values('RATE', ascending=False)
        df.index=range(len(df))
        # pass
    rowCount = int(df.iloc[:,0].size)+1
    columnCount = int(df.columns.size)
    print('rowCount:',rowCount)

    n_reference = 30
    rowPage = int(rowCount/n_reference)
    row_2 = rowCount%n_reference

    if rowCount <=n_reference+2:
        generate_retest_plot(df, title_name, pie_retest_csv_path, pic_path, 0, rowCount)
    else:

        for i in range(rowPage):
            if i == 0:
                generate_retest_plot(df, title_name, pie_retest_csv_path, pic_path, i*n_reference,i*n_reference+n_reference-1)
            else:

                pic_path_new = pic_path.replace('.png','') + str(i)+'.png'
                generate_retest_plot(df, title_name, pie_retest_csv_path, pic_path_new, i*n_reference,i*n_reference+n_reference-1)
            
        if row_2>1:
            pic_path_new = pic_path.replace('.png','') + str(i+1)+'.png'
            generate_retest_plot(df, title_name, pie_retest_csv_path, pic_path_new,rowPage*n_reference,rowPage*n_reference+row_2)



 

def generate_retest_plot(df_data,title_name,pie_retest_csv_path,pic_path,n_start, n_end):
    print('****************11***',n_start,n_end)
    df_count = pd.read_csv(pie_retest_csv_path)
    if len(df_count['TOTAL']) == 0:
        input_total_count = 0
    else:
        input_total_count= max(df_count['TOTAL'])

    print('******00000*******')
    max_y = 0
    plt.figure(figsize=(15,8))
    colorList = list(plt.cm.colors.cnames.keys())
    random.seed(100)
    c = random.choices(colorList, k=100)

    n_index = 0
    max_y = 0
    
    plt.style.use("seaborn")
    if len(df_data)>0:
        df = df_data.loc[n_start:n_end]
        print('******011111*******')
        df.index=range(len(df))
        
        xtick_location = df.index.tolist()[::1]
        xtick_labels = df.Index.tolist()[::1]
        
        xtick_retest_count = df.Retest_Count.tolist()[::1]
        xtick_total = df.TOTAL.tolist()[::1]

        # print('X_Y:',xtick_location,xtick_labels,xtick_retest_count,xtick_total)
        print('****************22***')
        for header_name in df.columns:
            if header_name == 'RATE':
                data = df[header_name].values
                print('---data:',data)
                plt.plot('Index', header_name, data=df, color=c[n_index], label='Total Input Count('+str(input_total_count)+')', alpha=1)
                if len(data) ==0:
                    max_data = 0
                else:
                    max_data = max(data)

                if max_y<max_data:
                    max_y = max_data
                n_index = n_index +1
                ii_n = 0
                for x0,y0 in zip(xtick_location,data):
                    # plt.text(x0,y0,y0,fontdict={'fontsize':11},alpha=0.6)
                    plt.text(x0,y0,('%s/%s') % (str(xtick_retest_count[ii_n]),str(xtick_total[ii_n])),fontdict={'fontsize':11},alpha=0.7)
                    ii_n = ii_n+1

            if header_name == 'OVERALL_RETEST_RATE':
                data = df[header_name].values
                percent_ref = data[0]
                try:
                    percent_ref = round(percent_ref,3)
                except Exception as e:
                    percent_ref = 0
                plt.plot('Index', header_name, data=df, linestyle=':', color='#000000', label='OVERALL_RETEST_RATE('+str(percent_ref)+'%)', alpha=0.6)

    
    if max_y ==0:
        max_y = 0.001
    plt.ylim(0,max_y*1.1)
    plt.plot('', '', color=c[n_index], label='Total Input Count(0)', alpha=1)
    plt.xticks(ticks=[0], labels=[''], rotation=45, fontsize=9, alpha=1)
    plt.title(title_name, fontsize=22)
    plt.yticks(fontsize=13, alpha=1)
    plt.ylabel("Percentage(%)",fontsize=15)
    plt.xticks(fontsize=13, alpha=1)
    # Lighten borders
    plt.gca().spines["top"].set_alpha(.0)
    plt.gca().spines["bottom"].set_alpha(.5)
    plt.gca().spines["right"].set_alpha(.0)
    plt.gca().spines["left"].set_alpha(.5)

    plt.legend(loc='upper left')
    # plt.grid(axis='x', alpha=.3)
    # plt.grid(axis='y', alpha=.4)
    plt.tight_layout() 
    plt.savefig(pic_path, dpi=200)
                        
                

def daily_retest_summary_plot(csv_path, pic_all_path, pic_path):

    isExists=os.path.exists(csv_path)
    if not isExists:
        plt.gca().spines["top"].set_alpha(.0)
        plt.gca().spines["bottom"].set_alpha(.5)
        plt.gca().spines["right"].set_alpha(.0)
        plt.gca().spines["left"].set_alpha(.5)
        plt.tight_layout() 
        plt.savefig(pic_path, dpi=200)
        return 
 
    data1= pd.read_csv(csv_path)
    df = pd.DataFrame(data1)
    rowCount = int(df.iloc[:,0].size)+1
    columnCount = int(df.columns.size)

    n_reference = 30
    rowPage = int(rowCount/n_reference)
    row_2 = rowCount%n_reference

    print('********!!***********')
    if rowCount <=n_reference + 2:
        print('*****@@@*********')
        generate_retest_summary_plot(df,pic_path,0,rowCount)
        generate_retest_all_summary_plot(df,pic_all_path,0,rowCount)
    else:

        for i in range(rowPage):
            if i == 0:
                generate_retest_summary_plot(df,pic_path,i*n_reference,i*n_reference+n_reference-1)
                generate_retest_all_summary_plot(df,pic_all_path,i*n_reference,i*n_reference+n_reference-1)
            else:
                pic_path_new = pic_path.replace('.png','') + str(i)+'.png'
                generate_retest_summary_plot(df,pic_path_new,i*n_reference,i*n_reference+n_reference-1)

                pic_all_path_new = pic_path.replace('.png','') + str(i)+'.png'
                generate_retest_all_summary_plot(df,pic_all_path_new,i*n_reference,i*n_reference+n_reference-1)
            
        if row_2>1:
            pic_path_new = pic_path.replace('.png','') + str(i+1)+'.png'
            generate_retest_summary_plot(df,pic_path_new,rowPage*n_reference,rowPage*n_reference+row_2)
            pic_all_path_new = pic_path.replace('.png','') + str(i+1)+'.png'
            generate_retest_all_summary_plot(df,pic_all_path_new,rowPage*n_reference,rowPage*n_reference+row_2)

def generate_retest_all_summary_plot(df_data, pic_path, n_start, n_end):
    plt.style.use("seaborn")
    df = df_data.loc[n_start:n_end]
    df.index=range(len(df))
    plt.figure(figsize=(15,8))
    colorList = list(plt.cm.colors.cnames.keys())
    random.seed(100)
    c = random.choices(colorList, k=100)

    n_index = 0
    max_y = 0
    xtick_location = df.index.tolist()[::1]
    xtick_labels = df.Date.tolist()[::1]
    
    for header_name in df.columns:
        if ('ALL_#RATE' in header_name):
            data = df[header_name].values
            xtick_retest_count = df[header_name.replace('_#RATE','')]
            xtick_total = df[header_name.replace('_#RATE','_#TOTAL')]

            xtick_retest_count_all = df_data[header_name.replace('_#RATE','')]
            xtick_total_all = df_data[header_name.replace('_#RATE','_#TOTAL')]

            plt.plot('Date', header_name, data=df, color= '#FE420F', label=header_name.replace('_#RATE','') + '('+str(sum(xtick_retest_count_all))+'/'+str(sum(xtick_total_all))+')', alpha=0.8)
            if len(data) == 0:
                max_data = 0
            else:
                max_data = max(data)

            ii_n = 0
            for x0,y0 in zip(xtick_location,data):
                plt.text(x0,y0,('%s/%s') % (str(xtick_retest_count[ii_n]),str(xtick_total[ii_n])),fontdict={'fontsize':11},alpha=1,color=c[n_index])
                ii_n = ii_n+1

            if max_y<max_data:
                max_y = max_data
            n_index = n_index +1


        if header_name == 'OVERALL_RETEST_RATE_#RATE':
            data = df[header_name].values
            xtick_percentage = df_data[header_name][0]
            try:
                xtick_percentage = round(xtick_percentage,3)
            except Exception as e:
                print('xtick_percentage',e)
                xtick_percentage = 0
            plt.plot('Date', header_name, data=df, linestyle=':', color='#000000', label=header_name.replace('_#RATE','') + '('+str(xtick_percentage)+'%)', alpha=0.6)

    
    if max_y ==0:
        max_y = 0.001
    plt.ylim(0,max_y*1.1)

    plt.xticks(ticks=xtick_location, labels=xtick_labels, rotation=45, fontsize=9, alpha=1)
    plt.title("Daily Retest Summary Chart All Product Wise", fontsize=22)
    plt.yticks(fontsize=13, alpha=1)
    plt.ylabel("Percentage(%)",fontsize=15)
    plt.xticks(fontsize=13, alpha=1)

    plt.gca().spines["top"].set_alpha(.0)
    plt.gca().spines["bottom"].set_alpha(.5)
    plt.gca().spines["right"].set_alpha(.0)
    plt.gca().spines["left"].set_alpha(.5)

    plt.legend(loc='upper left')
    plt.tight_layout() 
    plt.savefig(pic_path, dpi=200)

def generate_retest_summary_plot(df_data, pic_path, n_start, n_end):
    plt.style.use("seaborn")
    df = df_data.loc[n_start:n_end]
    df.index=range(len(df))
    plt.figure(figsize=(15,8))
    colorList = list(plt.cm.colors.cnames.keys())
    random.seed(100)
    # c = random.choices(colorList, k=100)
    c = ['#014182','#FF0000','#008000','#00FFFF','#9400D3','#F0833A','#B8860B','#FFA500','#A9A9A9','#FFFF00','#BFF128','#87A922','#B9CC81','#4B5D16','#5CB200','#B1FF65','#8EE53F','#58BC08','#4DA409','#C1FD95']
    n_index = 0
    max_y = 0
    xtick_location = df.index.tolist()[::1]
    xtick_labels = df.Date.tolist()[::1]
    

    for header_name in df.columns:
        if header_name != 'Date' and ('_#RATE' in header_name) and (header_name != 'OVERALL_RETEST_RATE_#RATE'):
            data = df[header_name].values
            xtick_retest_count = df[header_name.replace('_#RATE','')]
            xtick_total = df[header_name.replace('_#RATE','_#TOTAL')]

            xtick_retest_count_all = df_data[header_name.replace('_#RATE','')]
            xtick_total_all = df_data[header_name.replace('_#RATE','_#TOTAL')]

            plt.plot('Date', header_name, data=df, color=c[n_index%20], label=header_name.replace('_#RATE','') + '('+str(sum(xtick_retest_count_all))+'/'+str(sum(xtick_total_all))+')', alpha=0.8)
            if len(data) == 0:
                max_data = 0
            else:
                max_data = max(data)

            ii_n = 0
            for x0,y0 in zip(xtick_location,data):
                plt.text(x0,y0,('%s/%s') % (str(xtick_retest_count[ii_n]),str(xtick_total[ii_n])),fontdict={'fontsize':11},alpha=1,color=c[n_index])
                ii_n = ii_n+1

            if max_y<max_data:
                max_y = max_data
            n_index = n_index +1
    
        if header_name == 'OVERALL_RETEST_RATE_#RATE':
            data = df[header_name].values
            xtick_percentage = df_data[header_name][0]
            try:
                xtick_percentage = round(xtick_percentage,3)
            except Exception as e:
                print('xtick_percentage',e)
                xtick_percentage = 0
            plt.plot('Date', header_name, data=df, linestyle=':', color='#000000', label=header_name.replace('_#RATE','') + '('+str(xtick_percentage)+'%)', alpha=0.6)


    if max_y ==0:
        max_y = 0.001
    plt.ylim(0,max_y*1.1)

    plt.xticks(ticks=xtick_location, labels=xtick_labels, rotation=45, fontsize=9, alpha=1)
    plt.title("Daily Retest Summary Chart Product Wise", fontsize=22)
    plt.yticks(fontsize=13, alpha=1)
    plt.ylabel("Percentage(%)",fontsize=15)
    plt.xticks(fontsize=13, alpha=1)

    plt.gca().spines["top"].set_alpha(.0)
    plt.gca().spines["bottom"].set_alpha(.5)
    plt.gca().spines["right"].set_alpha(.0)
    plt.gca().spines["left"].set_alpha(.5)

    plt.legend(loc='upper left')
    plt.tight_layout() 
    plt.savefig(pic_path, dpi=200)


def pareto_plot(csv_path, pic_color, title, x=None, y=None, customer = None, show_pct_y=False, pct_format='{0:.0%}',saveas = None):
    df = pd.read_csv(csv_path)
    plt.style.use("seaborn")
    plt.figure(figsize=(23,10))
    # if customer != None:
    #     df = df[df['Supplier'].str.match(customer)]  # omits data not from supplier
    #title = 'Pareto Chart for Top 5 Retest'
    occurrences = df.groupby(x).count().reset_index()
    n_count = df[x].unique().__len__()+1
    ylabel = "Frequency of Occurrence"
    tmp = occurrences.sort_values(y, ascending=False)
    x = tmp[x].tolist()
    if len(x)>10:
        x = x[0:10]
        x.append('Others')
    
    x = [checkItemName(i,5,13) for i in x]
    y = tmp[y].tolist() 
    if len(y)>10:
        y_orig = y
        y = y_orig[0:10]
        y.append(sum(y_orig[10:]))

        
    # x = [str(x[i]) + '\n(' + str(y[i]) + ')' for i in range(min(len(x),len(y)))]
    # print(x)
    # print(y)
    #x = tmp[x].values
    #y = tmp[y].values
    
    # at this point, x should be an ordered list of x axis categories
    # and y should be the number of occurrences
    #weights = y / y.sum()

    weights = []
    # colorList = []
    for count in y:
        weights.append(count/sum(y))
    # for count in weights:
    #     colorList.append(count+(1-max(weights)))
    # print(weights)
    # print(colorList)
    colorList = list(plt.cm.colors.cnames.keys())
    colorList = colorList[2:]
    cumsum = []
    for counter,percent in enumerate(weights):
        cumsum.append(sum(weights[:counter+1]))
    # fig, ax1 = plt.subplots()
    fig, ax1 = plt.subplots(figsize=(15, 8))
    random.seed(100)
    c = random.choices(colorList, k=n_count)
    ax1.bar(x, y,color=pic_color,width=.5,alpha=0.8)
    #ax1.set_xlabel(xlabel)
    # ax1.set_ylabel(ylabel,fontsize=12)
    ax1.set_ylabel(ylabel)

    # plt.ylabel(ylabel,fontsize=15)
    if len(y)==0:
        ax1.set_ylim([0,1])
    else:
        ax1.set_ylim([0,max(y)*1.4])

    ax2 = ax1.twinx()
    ax2.plot(x, cumsum, '-s',color = "black",alpha=1)#, alpha=0.5)
    ax2.set_ylabel('', color='purple')
    ax2.tick_params('y')#, colors='purple') #right y axis label color
    ax2.set_ylim([0,1.05])
    ax2.grid(alpha = 0)
    # ax1.set_xticklabels(x,rotation=45,fontsize=13)
    ax1.set_xticklabels(x,rotation=45,fontsize=11)

    
    # vals = ax2.get_yticks()
    # label_format = '{:,.0%}'
    # xx =[label_format.format(x) for x in vals]
    # ax2.set_yticklabels(xx)

    # hide y-labels on right side
    if not show_pct_y:
        ax2.set_yticks([])
    formatted_weights = [pct_format.format(x) for x in cumsum]
    bbox_props = dict(boxstyle="round,pad=0.5", fc="w", ec="0", lw=.5,alpha=1)

    for i, txt in enumerate(formatted_weights):
        ax2.text(x[i], cumsum[i],txt, horizontalalignment='center',verticalalignment="bottom",bbox=bbox_props,fontdict={'fontweight':300, 'size':10})    
        yy = y[i]
        # y_value = cumsum[i]
        # if abs(yy - y_value)<0.5:
        #     yy = yy*1.07 # 防止数量标签被挡住
        ax1.text(x[i], yy, str(y[i]), horizontalalignment='center', verticalalignment='bottom', fontdict={'fontweight':400, 'size':10})
    plt.title(title,fontsize = 15)

    pie_retest_csv_path = '/tmp/CPK_Log/retest/.pie_retest.csv'
    df_count = pd.read_csv(pie_retest_csv_path)
    if len(df_count['TOTAL']) == 0:
        input_total_count = 0
    else:
        input_total_count= max(df_count['TOTAL'])

    ax1.legend(['Total Input Count('+str(input_total_count)+')'],loc="upper left",fontsize=8,frameon=False)
    # plt.plot(color=pic_color, label='Total Input Count('+str(input_total_count)+')', alpha=1)

    plt.tight_layout()  
    # plt.show()
    if saveas != None:
        fig.savefig(saveas, dpi=200)
    # df = pd.read_csv(csv_path)
    # plt.style.use("seaborn")
    # plt.figure(figsize=(15, 8), dpi=200)
    # # if customer != None:
    # #     df = df[df['Supplier'].str.match(customer)]  # omits data not from supplier
    # #title = 'Pareto Chart for Top 5 Retest'
    # occurrences = df.groupby(x).count().reset_index()
    # n_count = df[x].unique().__len__()+1
    # ylabel = "Frequency of Occurrence"
    # tmp = occurrences.sort_values(y, ascending=False)
    # x = tmp[x].tolist()
    # print('*********x:',len(x))
    # if len(x)>10:
    #     x = x[0:10]
    #     x.append('Others')

    
    # x = [checkItemName(i,5,13) for i in x]
    # print('*******',x)
    # y = tmp[y].tolist()
    # print('*****+++++++*****',y)
    # if len(y)>10:
    #     y_orig = y
    #     y = y_orig[0:10]
    #     # others = 0
    #     # for ele in range(0, len(y[10:])): 
    #     #     total = total + list1[ele] 
    #     print('++++++?????+++',y_orig[10:])
    #     y.append(sum(y_orig[11:]))

        
    # # x = [str(x[i]) + '\n(' + str(y[i]) + ')' for i in range(min(len(x),len(y)))]
    # # print(x)
    # # print(y)
    # #x = tmp[x].values
    # #y = tmp[y].values
    
    # # at this point, x should be an ordered list of x axis categories
    # # and y should be the number of occurrences
    # #weights = y / y.sum()

    # weights = []
    # # colorList = []
    # for count in y:
    #     weights.append(count/sum(y))
    # # for count in weights:
    # #     colorList.append(count+(1-max(weights)))
    # # print(weights)
    # # print(colorList)
    # colorList = list(plt.cm.colors.cnames.keys())
    # colorList = colorList[2:]
    # cumsum = []
    # for counter,percent in enumerate(weights):
    #     cumsum.append(sum(weights[:counter+1]))
    # # fig, ax1 = plt.subplots()
    # fig, ax = plt.subplots(figsize=(15, 8))
    # random.seed(100)
    # c = random.choices(colorList, k=n_count)
    # # ax1.bar(x, y,color=pic_color,width=.5,alpha=0.8)
    # # #ax1.set_xlabel(xlabel)
    # # # ax1.set_ylabel(ylabel,fontsize=12)
    # # ax1.set_ylabel(ylabel)

    # # plt.ylabel(ylabel,fontsize=15)
    # # if len(y)==0:
    # #     ax1.set_ylim([0,1])
    # # else:
    # #     ax1.set_ylim([0,max(y)*1.4])

    # # ax2 = ax1.twinx()
    # # ax2.plot(x, cumsum, '-s',color = "black",alpha=1)#, alpha=0.5)
    # # ax2.set_ylabel('', color='purple')
    # # ax2.tick_params('y')#, colors='purple') #right y axis label color
    # # ax2.set_ylim([0,1.05])
    # # ax2.grid(alpha = 0)
    # # ax1.set_xticklabels(x,rotation=45,fontsize=13)
    # # ax1.set_xticklabels(x,rotation=45,fontsize=6)

    
    # # vals = ax2.get_yticks()
    # # label_format = '{:,.0%}'
    # # xx =[label_format.format(x) for x in vals]
    # # ax2.set_yticklabels(xx)

    # # hide y-labels on right side
    # # if not show_pct_y:
    # #     ax2.set_yticks([])
    # # formatted_weights = [pct_format.format(x) for x in cumsum]
    # # bbox_props = dict(boxstyle="round,pad=0.5", fc="w", ec="0", lw=.5,alpha=1)

    # # for i, txt in enumerate(formatted_weights):
    #     # ax2.text(x[i], cumsum[i],txt, horizontalalignment='center',verticalalignment="bottom",bbox=bbox_props,fontdict={'fontweight':300, 'size':10})    
    #     # yy = y[i]
    #     # # y_value = cumsum[i]
    #     # # if abs(yy - y_value)<0.5:
    #     # #     yy = yy*1.07 # 防止数量标签被挡住
    #     # ax1.text(x[i], yy, str(y[i]), horizontalalignment='center', verticalalignment='bottom', fontdict={'fontweight':400, 'size':10})
    # # plt.title(title,fontsize = 12)

    # # pie_retest_csv_path = '/tmp/CPK_Log/retest/.pie_retest.csv'
    # # df_count = pd.read_csv(pie_retest_csv_path)
    # # if len(df_count['TOTAL']) == 0:
    # #     input_total_count = 0
    # # else:
    # #     input_total_count= max(df_count['TOTAL'])

    # # ax1.legend(['Total Input Count('+str(input_total_count)+')'],loc="upper left",fontsize=8,frameon=False)
    # # plt.plot(color=pic_color, label='Total Input Count('+str(input_total_count)+')', alpha=1)

    # plt.tight_layout()  
    # # plt.show()
    # if saveas != None:
    #     fig.savefig(saveas, dpi=200)



def generateRetestCSV(all_csv_path,retest_csv_path,pie_retest_csv_path,fail_csv_path,header_item_path):
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
        header_list = tmp_lst[1]
        df = pd.DataFrame(tmp_lst[2:], columns=tmp_lst[1])
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
        print('>>>>total_sn:',len(total_sn))

        pass_df=data_df[data_df['Test Pass/Fail Status'].isin(['PASS'])]
        # print('pass_df:',len(pass_df))
        overall_pass_sn = list(set(list((pass_df['SerialNumber'].values.tolist()))))
        # print('pass_sn:',len(overall_pass_sn))
        # print('--->>>',data_df['SerialNumber'])
        fail_df=data_df[data_df['Test Pass/Fail Status'].isin(['FAIL'])]
        overall_fail_sn = list(set(list((fail_df['SerialNumber'].values.tolist()))))

        no_retest_pass_sn = [x for x in overall_pass_sn if x not in overall_fail_sn]  #在list1列表中而不在list2列表中
        no_retest_pass_sn = list(set(no_retest_pass_sn))
        print('plot->no_retest_pass_sn',len(no_retest_pass_sn))

        
        true_fail_sn = [y for y in overall_fail_sn if y not in overall_pass_sn]  #在list2列表中而不在list1列表中
        true_fail_sn = list(set(true_fail_sn))

        # print('fail_df:',len(fail_df),len(overall_fail_sn))
        total_retest_sn = [z for z in overall_fail_sn if z in overall_pass_sn]  #在list2列表中而不在list1列表中
        total_retest_sn = list(set(total_retest_sn))


        keyword_list = ['STATION ID','SITE_ID']
        keyword_list2 = ['FIXTURE_SETUP CHANNEL CHANNEL_ID','FIXTURE CHANNEL ID','FIXTURE INITILIZATION SLOT_ID','FIXTURE RESET CALC FIXTURE_CHANNEL','HEAD ID','FIXTURE_CHANNEL CHANNEL CHANNEL_ID','FIXTURE CHANNEL CHANNEL_ID','CHANNEL ID','CHANNEL_ID','SLOT ID','SLOT_ID']
        #Fixture_Setup Channel Channel_id
        global station_id_key
        global slot_id_key

        for keyword in keyword_list:
            header_data = [s.upper() for s in data_df.columns if isinstance(s,str)==True]
            n_count = 0
            for item_data in header_data:
                if keyword == item_data:
                    station_id_key = data_df.columns[n_count]
                    break
                n_count = n_count + 1

        for keyword in keyword_list2:
            header_data = [s.upper() for s in data_df.columns if isinstance(s,str)==True]
            n_count = 0
            for item_data in header_data:
                if keyword == item_data:
                    slot_id_key = data_df.columns[n_count]
                    break
                n_count = n_count + 1

        f_csv = open(retest_csv_path,'w',encoding='utf-8')
        csv_writer = csv.writer(f_csv)
        csv_writer.writerow(['Date','SerialNumber','RetestItem','Product','Station ID','Version','Slot ID','Measured Value','[LSL;USL]'])

        total_temp_p_l=[]
        total_temp_r_l=[]

        for retest_sn in total_retest_sn:
            if retest_sn !='':
                start_time_l = list(data_df.loc[ data_df['SerialNumber'] == retest_sn, 'StartTime'].tolist())
                first_test_time = min(start_time_l)
                sn_status = list(data_df.loc[ data_df['StartTime'].isin([first_test_time]) & (data_df['SerialNumber'] == retest_sn), 'Test Pass/Fail Status'].tolist())
                
                if sn_status == ['PASS']:
                    total_temp_p_l = total_temp_p_l + [retest_sn]

                elif sn_status == ['FAIL']:
                    total_temp_r_l = total_temp_r_l + [retest_sn]

                    fail_list = list(data_df.loc[data_df['StartTime'].isin([first_test_time]) & (data_df['SerialNumber'] == retest_sn), 'List of Failing Tests'].tolist())
                    product_list = list(data_df.loc[data_df['StartTime'].isin([first_test_time]) & (data_df['SerialNumber'] == retest_sn), 'Product'].tolist())
                    # print('fail_list:',retest_sn, fail_list,product_list[0])
                    fail_list_first_item = fail_list[0].split(';',1)[0]

                    if station_id_key == '':
                        station_id_list = ['']
                    else:
                        station_id_list = list(data_df.loc[data_df['StartTime'].isin([first_test_time]) & (data_df['SerialNumber'] == retest_sn), station_id_key].tolist())
                    
                    if slot_id_key == '':
                        slot_id_list = ['']
                    else:
                        slot_id_list = list(data_df.loc[data_df['StartTime'].isin([first_test_time]) & (data_df['SerialNumber'] == retest_sn), slot_id_key].tolist())
                    
                    
                    version_list = list(data_df.loc[data_df['StartTime'].isin([first_test_time]) & (data_df['SerialNumber'] == retest_sn), 'Version'].tolist())
                    try:
                        measured_value = list(data_df.loc[data_df['StartTime'].isin([first_test_time]) & (data_df['SerialNumber'] == retest_sn), fail_list_first_item].tolist())
                    except Exception as e:
                        # print('error measured_value'+ str(e))
                        measured_value = ['']
                    try:
                        limit_value = '['+str(header_df[fail_list_first_item][1])+';'+str(header_df[fail_list_first_item][0])+']'
                    except Exception as e:
                        # print('error limit_value'+ str(e)) 
                        limit_value = ''
                    csv_writer.writerow([first_test_time,retest_sn,fail_list_first_item,product_list[0],str(station_id_list[0]),str(version_list[0]),str(slot_id_list[0]),str(measured_value[0]),limit_value])
                else:
                    print('>no test status')
                    total_temp_p_l = total_temp_p_l + [retest_sn]

        f_csv.close()

        print('plot->total_temp_p_l',len(total_temp_p_l),len(total_temp_r_l),len(true_fail_sn))
        total_count = len(no_retest_pass_sn+total_temp_p_l+true_fail_sn+total_temp_r_l)
        total_fail_sn = true_fail_sn
        fail_count = len(total_fail_sn)
        no_retest_pass_count = len(no_retest_pass_sn)
        first_pass_count = len(no_retest_pass_sn) + len(list(set(total_temp_p_l)))
        pass_count = len(no_retest_pass_sn+total_retest_sn)
        total_retest_sn_no_first_pass = list(set(total_temp_r_l))

        f_csv = open(pie_retest_csv_path,'w',encoding='utf-8')
        csv_writer = csv.writer(f_csv)
        csv_writer.writerow(['1st PASS','Retest PASS','FAILED','PASSED','No Retest PASS','TOTAL'])
        csv_writer.writerow([str(first_pass_count),str(len(total_retest_sn_no_first_pass)),str(fail_count),str(pass_count),str(no_retest_pass_count),str(total_count)])
        f_csv.close()

        f_csv = open(fail_csv_path,'w',encoding='utf-8')
        csv_writer = csv.writer(f_csv)
        csv_writer.writerow(['Date','SerialNumber','FailItem'])
        data_df2 = data_df[data_df['Test Pass/Fail Status'] == 'FAIL']
        for fail_sn in true_fail_sn:
            start_time_l = list(data_df2.loc[data_df['SerialNumber'] == fail_sn, 'StartTime'].tolist())
            first_test_time = min(start_time_l)
            fail_list = list(data_df2.loc[data_df['SerialNumber']==fail_sn, 'List of Failing Tests'].tolist())
            fail_list_first_item = fail_list[0].split(';',1)[0]
            csv_writer.writerow([str(first_test_time),str(fail_sn),fail_list_first_item])
        f_csv.close()


        f_csv = open(header_item_path,'w',encoding='utf-8')
        csv_writer = csv.writer(f_csv)
        try:
            product_list=list(set(list((data_df['Product'].values.tolist()))))
        except Exception as e:
            print('error product_list',str(e))
            product_list = ['']

        csv_writer.writerow(product_list)

        try:
            if station_id_key == '':
                station_id_list = ['']
            else:
                station_id_list=list(set(list((data_df[station_id_key].values.tolist()))))

            if slot_id_key == '':
                slot_id_list = ['']
            else:
                slot_id_list=list(set(list((data_df[slot_id_key].values.tolist()))))
                # slot_id_list=[x for x in slot_id_list_tmp if x.strip() != '']

        except Exception as e:
            print('error station_id_key',str(e))
            station_id_list = ['']
            slot_id_list = ['']
        
        station_slot_id_list = []
        tation_slot_id_list_orig = []
        for station_id in station_id_list:
            for slot_id in slot_id_list:

                if slot_id == '':
                    station_slot_id_list.append(cut_station_name(str(station_id)))
                    tation_slot_id_list_orig.append(str(station_id))

                else:

                    station_slot_id_list.append(cut_station_name(str(station_id))+' '+str(slot_id))
                    tation_slot_id_list_orig.append(str(station_id)+' '+str(slot_id))

        csv_writer.writerow(station_slot_id_list)
        csv_writer.writerow(station_id_list)
        csv_writer.writerow(slot_id_list)

        try:
            version_list=list(set(list((data_df['Version'].values.tolist()))))
        except Exception as e:
            print('error version_list',str(e))
            version_list = ['']
        csv_writer.writerow(version_list)

        try:
            date_total_list = []
            for single_sn in total_sn:
                date_time_list_tmp = list(data_df.loc[(data_df['SerialNumber'] == single_sn), 'StartTime'].tolist())
                date_time_tstr_mp = pd.to_datetime(str(date_time_list_tmp[0])).strftime("%Y/%m/%d")
                date_total_list.append(str(date_time_tstr_mp))
            
            date_list = sorted(list(set(date_total_list)))
        except Exception as e:
            print('error version_list',str(e))
            date_list = ['2020-00-00','2020-00-00']
        csv_writer.writerow(date_list)

        f_csv.close()



# =====================by station id and slot id, by version, by date=======================
        # n_total_name_by_product_list = [groupName for groupName, groupDf in data_df.groupby(data_df='Product')]
        # n_total_date_by_product_list = []
        # for x_date in data_df['StartTime']:
        #     date_time = pd.to_datetime(x_date).strftime("%Y/%m/%d")
        #     n_total_date_by_product_list.append(date_time)
        # n_total_date_by_product_list = sorted(list(set(n_total_date_by_product_list)))


        n_total_count_by_station_list = []
        n_first_pass_value_list = []

        n_total_count_by_version_list = []
        n_first_pass_value_by_version_list = []

        n_total_count_by_date_list = []
        n_first_pass_by_date_list = []
        print('-1>no_retest_pass_sn',len(no_retest_pass_sn))
        print('-1>true_fail_sn',len(true_fail_sn))
        print('-1>total_retest_sn',len(total_retest_sn))
        
        for no_retest_pass_sn_value in no_retest_pass_sn:
            try:
                station_id_list_pass = list(data_df.loc[(data_df['SerialNumber'] == no_retest_pass_sn_value), station_id_key].tolist())
                
                if slot_id_key == '':
                    n_first_pass_value_list.append(str(station_id_list_pass[0]))

                else:
                    slot_id_list_pass = list(data_df.loc[(data_df['SerialNumber'] == no_retest_pass_sn_value), slot_id_key].tolist())
                    if slot_id_list_pass[0].strip() == '':
                        n_first_pass_value_list.append(str(station_id_list_pass[0]))
                    else:
                        n_first_pass_value_list.append(str(station_id_list_pass[0])+' '+str(slot_id_list_pass[0]))


                version_list_pass = list(data_df.loc[(data_df['SerialNumber'] == no_retest_pass_sn_value), 'Version'].tolist())
                n_first_pass_value_by_version_list.append(str(version_list_pass[0]))

                date_time_list_pass = list(data_df.loc[(data_df['SerialNumber'] == no_retest_pass_sn_value), 'StartTime'].tolist())
                date_time_only_day_list_pass = pd.to_datetime(str(date_time_list_pass[0])).strftime("%Y/%m/%d")

                product_list_pass = list(data_df.loc[(data_df['SerialNumber'] == no_retest_pass_sn_value), 'Product'].tolist())
                n_first_pass_by_date_list.append(str(date_time_only_day_list_pass)+' '+ str(product_list_pass[0]))

            except Exception as e:
                print('list no retest sn error'+ str(e))
        

        #   first pass

        n_first_pass_value_set = set(n_first_pass_value_list)
        print('>:n_first_pass_value_list',len(n_first_pass_value_list))
        for n_first_pass_item in n_first_pass_value_set:
            # print('-first pass>>>',n_first_pass_item,n_first_pass_value_list.count(n_first_pass_item))
            tmp_pass_1 = []
            tmp_pass_1.append(n_first_pass_item)
            tmp_pass_1.append(n_first_pass_value_list.count(n_first_pass_item))
            n_total_count_by_station_list.append(tmp_pass_1)

        n_first_pass_value_by_version_set = set(n_first_pass_value_by_version_list)
        for n_first_pass_item in n_first_pass_value_by_version_set:
            tmp_pass_1 = []
            tmp_pass_1.append(n_first_pass_item)
            tmp_pass_1.append(n_first_pass_value_by_version_list.count(n_first_pass_item))
            n_total_count_by_version_list.append(tmp_pass_1)
        
        n_first_pass_by_date_list_set = set(n_first_pass_by_date_list)
        for n_first_pass_item in n_first_pass_by_date_list_set:
            tmp_pass_1 = []
            tmp_pass_1.append(n_first_pass_item)
            tmp_pass_1.append(n_first_pass_by_date_list.count(n_first_pass_item))
            n_total_count_by_date_list.append(tmp_pass_1)


        #  true fail
        n_true_fail_value_list = [] 
        n_true_fail_value_by_version_list = [] 
        n_true_fail_value_by_date_list = [] 

        for true_fail_sn_value in true_fail_sn:
            try:
                station_id_list_fail = list(data_df.loc[(data_df['SerialNumber'] == true_fail_sn_value), station_id_key].tolist())
                
                if slot_id_key =='':
                    n_true_fail_value_list.append(str(station_id_list_fail[0]))
                else:

                    slot_id_list_fail = list(data_df.loc[(data_df['SerialNumber'] == true_fail_sn_value), slot_id_key].tolist())
                    if slot_id_list_fail[0].strip() == '':
                        n_true_fail_value_list.append(str(station_id_list_fail[0]))
                    else:
                        n_true_fail_value_list.append(str(station_id_list_fail[0])+' '+str(slot_id_list_fail[0]))

                version_list_fail = list(data_df.loc[(data_df['SerialNumber'] == true_fail_sn_value), 'Version'].tolist())
                n_true_fail_value_by_version_list.append(str(version_list_fail[0]))

                date_time_list_fail = list(data_df.loc[(data_df['SerialNumber'] == true_fail_sn_value), 'StartTime'].tolist())
                date_time_only_day_list_fail = pd.to_datetime(str(date_time_list_fail[0])).strftime("%Y/%m/%d")

                product_list_fail = list(data_df.loc[(data_df['SerialNumber'] == true_fail_sn_value), 'Product'].tolist())
                n_true_fail_value_by_date_list.append(str(date_time_only_day_list_fail)+' '+ str(product_list_fail[0]))



            except Exception as e:
                print('list no retest sn error'+ str(e))
        n_true_fail_value_set = set(n_true_fail_value_list)
        for n_true_fail_item in n_true_fail_value_set:
            tmp_fail_1 = []
            # print('-aab fail>>>',n_true_fail_item,n_true_fail_value_list.count(n_true_fail_item))
            tmp_fail_1.append(n_true_fail_item)
            tmp_fail_1.append(n_true_fail_value_list.count(n_true_fail_item))
            n_total_count_by_station_list.append(tmp_fail_1)

        n_true_fail_value_by_version_set = set(n_true_fail_value_by_version_list)
        for n_true_fail_item in n_true_fail_value_by_version_set:
            tmp_fail_1 = []
            # print('-aab fail>>>',n_true_fail_item,n_true_fail_value_list.count(n_true_fail_item))
            tmp_fail_1.append(n_true_fail_item)
            tmp_fail_1.append(n_true_fail_value_by_version_list.count(n_true_fail_item))
            n_total_count_by_version_list.append(tmp_fail_1)

        n_true_fail_value_by_date_set = set(n_true_fail_value_by_date_list)
        for n_true_fail_item in n_true_fail_value_by_date_set:
            tmp_pass_1 = []
            tmp_pass_1.append(n_true_fail_item)
            tmp_pass_1.append(n_true_fail_value_by_date_list.count(n_true_fail_item))
            n_total_count_by_date_list.append(tmp_pass_1)



        #  retest
        n_retest_value_by_station_list = []
        n_retest_value_by_version_list = []
        n_retest_value_by_date_list = []
        # n_total_count_by_station_list_only_retest = []
        # n_total_count_by_version_list_only_retest = []

        for total_retest_sn_value in total_retest_sn:
            try:
                station_id_list_retest= list(data_df.loc[(data_df['SerialNumber'] == total_retest_sn_value), station_id_key].tolist())
                
                if slot_id_key == '':
                    n_retest_value_by_station_list.append(str(station_id_list_retest[0]))
                else:

                    slot_id_list_retest = list(data_df.loc[(data_df['SerialNumber'] == total_retest_sn_value), slot_id_key].tolist())
                    if slot_id_list_retest[0].strip() == '':
                        n_retest_value_by_station_list.append(str(station_id_list_retest[0]))
                    else:
                        n_retest_value_by_station_list.append(str(station_id_list_retest[0])+' '+str(slot_id_list_retest[0]))

                version_list_retest = list(data_df.loc[(data_df['SerialNumber'] == total_retest_sn_value), 'Version'].tolist())
                n_retest_value_by_version_list.append(str(version_list_retest[0]))

                date_time_list_fail = list(data_df.loc[(data_df['SerialNumber'] == total_retest_sn_value), 'StartTime'].tolist())
                date_time_only_day_list_fail = pd.to_datetime(str(date_time_list_fail[0])).strftime("%Y/%m/%d")

                product_list_fail = list(data_df.loc[(data_df['SerialNumber'] == total_retest_sn_value), 'Product'].tolist())
                n_retest_value_by_date_list.append(str(date_time_only_day_list_fail)+' '+ str(product_list_fail[0]))

            except Exception as e:
                print('list no retest sn error'+ str(e))

        n_retest_value_by_station_set = set(n_retest_value_by_station_list)
        for n_retest_item in n_retest_value_by_station_set:
            tmp_retest_1 = []
            tmp_retest_1.append(n_retest_item)
            tmp_retest_1.append(n_retest_value_by_station_list.count(n_retest_item))
            n_total_count_by_station_list.append(tmp_retest_1)
            # n_total_count_by_station_list_only_retest.append(tmp_retest_1)

        n_retest_value_by_version_set = set(n_retest_value_by_version_list)
        for n_retest_item in n_retest_value_by_version_set:
            tmp_retest_1 = []
            tmp_retest_1.append(n_retest_item)
            tmp_retest_1.append(n_retest_value_by_version_list.count(n_retest_item))
            n_total_count_by_version_list.append(tmp_retest_1)
            # n_total_count_by_version_list_only_retest.append(tmp_retest_1)

        n_retest_value_by_date_set = set(n_retest_value_by_date_list)
        for n_reset_item in n_retest_value_by_date_set:
            tmp_pass_1 = []
            tmp_pass_1.append(n_reset_item)
            tmp_pass_1.append(n_retest_value_by_date_list.count(n_reset_item))
            n_total_count_by_date_list.append(tmp_pass_1)
  

        df_station_slot_id = pd.DataFrame(n_total_count_by_station_list, columns=['Station ID Slot ID','TOTAL'])
        # df_station_slot_id_only_retest = pd.DataFrame(n_total_count_by_station_list_only_retest, columns=['Station ID Slot ID','RETEST'])
        # print('--->2>>>',n_total_count_by_station_list_only_retest,df_station_slot_id_only_retest)
        print('>generate total_count_by_station_slot_id.csv')
        f_csv = open('/tmp/CPK_Log/retest/..total_count_by_station_slot_id.csv','w',encoding='utf-8')
        csv_writer = csv.writer(f_csv)
        csv_writer.writerow(['Station ID Slot ID','TOTAL'])

        for groupName, groupDf in df_station_slot_id.groupby(by='Station ID Slot ID'):
            total_num = 0
            for index,row in groupDf.iterrows():
                    total_num = total_num+row['TOTAL']


            if slot_id_key == '':
                station_name_1 = cut_station_name(str(groupName))
                csv_writer.writerow([str(station_name_1),str(total_num)])
                
            else:
                if groupName.find(' ')>=0:
                    group_name_sub = groupName.rsplit(' ',1)
                    station_name_1 = cut_station_name(str(group_name_sub[0]))
                    slot_name_1 = str(group_name_sub[1])
                    csv_writer.writerow([str(station_name_1)+' '+slot_name_1,str(total_num)])
                else:
                    group_name_sub = groupName
                    station_name_1 = cut_station_name(str(group_name_sub))
                    csv_writer.writerow([str(station_name_1),str(total_num)])

        f_csv.close()

        df_version = pd.DataFrame(n_total_count_by_version_list, columns=['Version','TOTAL'])
        f_csv = open('/tmp/CPK_Log/retest/..total_count_by_version.csv','w',encoding='utf-8')
        csv_writer = csv.writer(f_csv)
        csv_writer.writerow(['Version','TOTAL'])

        for groupName, groupDf in df_version.groupby(by='Version'):
            total_num = 0
            for index,row in groupDf.iterrows():
                    total_num = total_num+row['TOTAL']

            csv_writer.writerow([str(groupName),str(total_num)])
        f_csv.close()


        f_date = pd.DataFrame(n_total_count_by_date_list, columns=['Date Product','TOTAL'])
        f_csv = open('/tmp/CPK_Log/retest/..total_count_by_date_product.csv','w',encoding='utf-8')
        csv_writer = csv.writer(f_csv)
        csv_writer.writerow(['Date','Date Product','TOTAL'])
        # print('------pdate product--')
        for groupName, groupDf in f_date.groupby(by='Date Product'):
            total_num = 0
            for index,row in groupDf.iterrows():
                    total_num = total_num+row['TOTAL']
            group_date = groupName.rsplit(' ',1)
            csv_writer.writerow([str(group_date[0]),str(groupName),str(total_num)])
        f_csv.close()

        if slot_id_key == '':
            yield_path = '/tmp/CPK_Log/temp/yield_rate_param.csv'
            isExists=os.path.exists(yield_path)
            if not isExists:
                for x in range(30):
                    time.sleep(2)
                    isExists=os.path.exists(yield_path)
                    if isExists:
                        break


            with open(yield_path,'r') as csvfile:
                reader = csv.reader(csvfile)
                yield_rows = [row for row in reader]

            f_csv = open('/tmp/CPK_Log/retest/..total_count_by_station_slot_id.csv','w',encoding='utf-8')
            csv_writer = csv.writer(f_csv)
            csv_writer.writerow(['Station ID Slot ID','TOTAL'])
            n_count = 0
            for yield_row in yield_rows:
                if n_count>1:
                    csv_writer.writerow([str(cut_station_name(yield_row[0])),str(yield_row[1])])
                n_count = n_count +1


            f_csv.close()




def func_pie(pct, allvals):
    absolute = int(round(pct/100.*np.sum(allvals),1))
    return "{:.1f}% ({:d} )".format(pct, absolute)

def pie_retest_plot(csv_pah,pic_path):
    # df_raw = pd.read_csv('/Users/RyanGao/Downloads/ParetoChart-master-2/pie.csv')
    # df = df_raw.groupby('class').size().reset_index(name='counts')

    # Draw Plot
    df = pd.read_csv(csv_pah)
    fig, ax = plt.subplots(figsize=(10, 6), subplot_kw=dict(aspect="equal"), dpi= 150)
    
    categories = ['1st PASS','Retest PASS','FAILED'] #df['class']
    data = [int(max(df[categories[0]])),int(max(df[categories[1]])),int(max(df[categories[2]]))]
    explode = [0,0.1,0]



    wedges, texts, autotexts = ax.pie(data, 
                                      autopct=lambda pct: func_pie(pct, data),
                                      textprops=dict(color="w"), 
                                      colors= ['lightskyblue','lightyellow','pink'], #plt.cm.Dark2.colors,
                                      startangle=140,
                                      explode=explode)

    # Decoration
    ax.legend(wedges, categories, title="Color Description:", loc="center left", bbox_to_anchor=(1, 0, 0.5, 1))
    plt.setp(autotexts, size=10, weight=700,color = 'blue',alpha = 0.7)
    ax.set_title("Pie Chart for Yield")
    plt.tight_layout() 
    plt.savefig(pic_path, dpi=150)
    # plt.show()


def yield_donut(csv_pah,pic_path):
    df = pd.read_csv(csv_pah)
    categories = ['1st PASS','Retest PASS','FAILED','PASSED','No Retest PASS','TOTAL']  #1st PASS,Retest PASS,FAILED,PASSED,No Retest PASS,TOTAL
    the_first_pass_count = max(df[categories[0]])
    the_second_pass_count = max(df[categories[1]])
    fail_count = max(df[categories[2]])
    total_count = max(df[categories[5]])
    
    first_pass_rate = float(the_first_pass_count)/float(total_count)
    send_pass_rate = float(the_second_pass_count)/float(total_count)
    fail_rate = float(fail_count)/float(total_count)
    fig, ax = plt.subplots(figsize=(12, 9), subplot_kw=dict(aspect="equal"))
    recipe = ["1st PASS:"+str(round(first_pass_rate*100,2))+"%",
              "Retest PASS:"+str(round(send_pass_rate*100,2))+"%",
              "AAB FAILED:"+str(round(fail_rate*100,2))+"%"]

    data = [first_pass_rate,send_pass_rate,fail_rate]
    colors = ['limegreen','yellow','red']
    wedges, texts = ax.pie(data, wedgeprops=dict(width=0.5), startangle=-40,colors=colors,)
    lend=[u'1st PASS:'+str(the_first_pass_count)+"/"+str(total_count),u'Retest PASS:'+str(the_second_pass_count)+"/"+str(total_count),u'AAB FAILED:'+str(fail_count)+"/"+str(total_count)]
    bbox_props = dict(boxstyle="square,pad=0.3", fc="w", ec="k", lw=0.72)
    kw = dict(xycoords='data', textcoords='data', arrowprops=dict(arrowstyle="-"),bbox=bbox_props, zorder=0, va="center")
    
    for i, p in enumerate(wedges):                                            # 遍历每一个扇形
    
        ang = (p.theta2 - p.theta1)/2. + p.theta1                             # 锁定扇形夹角的中间位置，对应的度数为ang
    
        y = np.sin(np.deg2rad(ang))                                           # np.sin()求正弦
        x = np.cos(np.deg2rad(ang))                                           # np.cos()求余弦
        horizontalalignment = {-1: "right", 1: "left"}[int(np.sign(x))]

        connectionstyle = "angle,angleA=0,angleB={}".format(ang)             # 参数connectionstyle用于控制箭头连接时的弯曲程度
        kw["arrowprops"].update({"connectionstyle": connectionstyle})        # 将connectionstyle更新至参数集kw的参数arrowprops中
        
        if i==2:
            ax.annotate(recipe[i], size=15, xy=(x, y), xytext=(1*np.sign(x), 1.05*y),horizontalalignment=horizontalalignment, **kw)
        else:
            ax.annotate(recipe[i], size=15, xy=(x, y), xytext=(1*np.sign(x), 1.2*y),horizontalalignment=horizontalalignment, **kw)
        # ax.annotate(recipe[i], size=15, xy=(x, y), xytext=(1*np.sign(x), 1.1*y),horizontalalignment=horizontalalignment, **kw)

    ax.set_title("Build Yield Chart",fontsize=20)
    plt.legend(lend,loc="center",fontsize=15,bbox_to_anchor=(0.5,0.5),borderaxespad=0.3,edgecolor='silver',shadow=True,labelspacing=0.5)
    plt.tight_layout() 
    plt.savefig(pic_path, dpi=150)


def retest_top_5_to_csv(retest_csv_path,pie_retest_csv_path,retest_top_5_path):
    df = pd.read_csv(retest_csv_path)
    occurrences = df.groupby('RetestItem').count().reset_index()
    n_count = df['RetestItem'].unique().__len__()+1
    tmp = occurrences.sort_values('SerialNumber', ascending=False)

    item_names = tmp['RetestItem'].tolist()
    retest_counts = tmp['SerialNumber'].tolist()

    total_retest_count = sum(retest_counts)

    if len(item_names)>5:
        item_names = item_names[0:5]

    if len(retest_counts)>5:
        retest_counts = retest_counts[0:5]

    # df = pd.read_csv('/tmp/CPK_Log/retest/.pie_retest.csv')
    df = pd.read_csv(pie_retest_csv_path)
    if len(df['TOTAL']) == 0:
        input_total_count = 0
    else:
        input_total_count= max(df['TOTAL'])

    f_csv = open(retest_top_5_path,'w',encoding='utf-8')
    csv_writer = csv.writer(f_csv)
    csv_writer.writerow(['Input (TOTAL)',str(input_total_count),'****'])
    csv_writer.writerow(['Top 5 Retest Items','Qty','Fail rate'])

    ii = 0
    for item_name in item_names:
        perct = round((float(retest_counts[ii])/float(input_total_count))*100,3)
        csv_writer.writerow([str(item_names[ii]),str(retest_counts[ii]),str(perct)+'%'])
        ii = ii+1          
    f_csv.close()

def fail_top_5_to_csv(fail_csv_path,pie_retest_csv_path,fail_top_5_path):
    df = pd.read_csv(fail_csv_path)
    occurrences = df.groupby('FailItem').count().reset_index()
    n_count = df['FailItem'].unique().__len__()+1
    tmp = occurrences.sort_values('SerialNumber', ascending=False)

    item_names = tmp['FailItem'].tolist()
    fail_counts = tmp['SerialNumber'].tolist()

    total_fail_count = sum(fail_counts)

    if len(item_names)>5:
        item_names = item_names[0:5]

    if len(fail_counts)>5:
        fail_counts = fail_counts[0:5]

    df = pd.read_csv(pie_retest_csv_path)
    input_total_count= max(df['TOTAL'])

    f_csv = open(fail_top_5_path,'w',encoding='utf-8')
    csv_writer = csv.writer(f_csv)
    csv_writer.writerow(['Input (TOTAL)',str(input_total_count),'****'])
    csv_writer.writerow(['Top 5 Fail Items','Qty','Fail rate'])

    ii = 0
    for item_name in item_names:
        perct = round((float(fail_counts[ii])/float(input_total_count))*100,3)
        csv_writer.writerow([str(item_names[ii]),str(fail_counts[ii]),str(perct)+'%'])
        ii = ii+1          
    f_csv.close()

def find_diff_intwo_list(list1,list2):
    '''
    :param list1: 列表1
    :param list2: 列表2
    :return:
    '''
    same,diff=[],[]
    seq=list(set(list2))
    for i in list(set(list1)):
        if i not in list2:
            diff.append(i)
        else:
            same.append(i)
    for j in same:
        seq.remove(j)
 
    # print("same is {},diff is {}".format(same,diff+seq))
    return diff+seq

def retest_vs_station_slot_id_csv(csv_data_path,header_item_path,keyword,csv_path_output):

    data0 = pd.read_csv('/tmp/CPK_Log/retest/..total_count_by_station_slot_id.csv')
    df0 = pd.DataFrame(data0)

    data1 = pd.read_csv(csv_data_path,keep_default_na=False)
    df = pd.DataFrame(data1)

    with open(header_item_path,'r') as csvfile:
        reader = csv.reader(csvfile)
        header_rows = [row for row in reader]

    list_station_id = []
    list_retest_count = []
    list_total_count = []
    list_rate_percent = []
    print('********(((********')
    for groupName, groupDf in df.groupby(by=keyword[0]): #'Station ID'

        if slot_id_key == '':
            n_count = 0
            for index,row in groupDf.iterrows():
                n_count = n_count + 1
            tmp_name = cut_station_name(str(groupName))
            list_station_id.append(tmp_name)
            list_retest_count.append(n_count)
            tt_list = list(df0.loc[(df0['Station ID Slot ID'] == tmp_name), 'TOTAL'].tolist())

            try:
                xx_tmp = tt_list[0]
            except Exception as e:
                # print('for tt_list[0]:',e)
                xx_tmp = 0

            list_total_count.append(str(xx_tmp))

            try:
                if int(xx_tmp) == 0:
                    list_rate_percent.append('0')
                else:
                    x_percent = round(int(n_count)/int(xx_tmp)*100,3)
                    list_rate_percent.append(str(x_percent))
            except Exception as e:
                print('error convert int',str(e))
                list_rate_percent.append('0')

        else:
            for groupName_sub, groupDf_sub in groupDf.groupby(by=keyword[1]):
                # print('>groupName',str(groupName),str(groupName_sub))
                n_count = 0
                for index,row in groupDf_sub.iterrows():
                    n_count = n_count + 1

                if str(groupName_sub).strip() == '':
                    tmp_name = cut_station_name(str(groupName))
                else:
                    tmp_name = cut_station_name(str(groupName)) + ' '+str(groupName_sub)

                if tmp_name not in list_station_id:
                    list_station_id.append(tmp_name)
                    list_retest_count.append(n_count)
                    tt_list = list(df0.loc[(df0['Station ID Slot ID'] == tmp_name), 'TOTAL'].tolist())

                try:
                    xx_tmp = tt_list[0]
                except Exception as e:
                    # print('for tt_list[0]:',e)
                    xx_tmp = 0

                list_total_count.append(str(xx_tmp))

                try:
                    if int(xx_tmp) == 0:
                        list_rate_percent.append('0')
                    else:
                        x_percent = round(int(n_count)/int(xx_tmp)*100,3)
                        list_rate_percent.append(str(x_percent))
                except Exception as e:
                    print('error convert int',str(e))
                    list_rate_percent.append('0')
            

    print("*******33333******")

    f_csv = open(csv_path_output,'w',encoding='utf-8')
    csv_writer = csv.writer(f_csv)
    csv_writer.writerow(['Index','Retest_Count','TOTAL','RATE','OVERALL_RETEST_RATE'])


    pie_retest_csv_path = '/tmp/CPK_Log/retest/.pie_retest.csv'
    df_count = pd.read_csv(pie_retest_csv_path)
    if len(df_count['TOTAL']) == 0:
        input_total_count = 0
    else:
        input_total_count= max(df_count['TOTAL'])

    if len(df_count['Retest PASS']) == 0:
        retest_pass_total = 0
    else:
        retest_pass_total= max(df_count['Retest PASS'])
    if input_total_count == 0 or retest_pass_total == 0:
        percantage_retest = 0
    else:
        percantage_retest = round(float(retest_pass_total)/float(input_total_count)*100,3)

    print("*******34444******")
    # print('>list_station_id:',list_station_id)
    n_index = 0
    for x_row in list_station_id:
        csv_writer.writerow([str(list_station_id[n_index]),str(list_retest_count[n_index]),str(list_total_count[n_index]),str(list_rate_percent[n_index]),str(percantage_retest)])
        n_index = n_index+1

    diff_list = find_diff_intwo_list(list_station_id,header_rows[1])
    # print('>diff_list:',diff_list)
    print("*******5554******")
    for diff_value in diff_list:

        if len(diff_value) > 0:
            print("*******6666******")

            tt_list = list(df0.loc[(df0['Station ID Slot ID'] == diff_value), 'TOTAL'].tolist())
            print("*******777******")
            try:
                xx_tmp = tt_list[0]
            except Exception as e:
                # print('for tt_list[0]:',e)
                xx_tmp = 0
            if xx_tmp !=0:
                csv_writer.writerow([str(diff_value),'0',str(xx_tmp),'0',str(percantage_retest)])


    f_csv.close()


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

def retest_breakdown_by_fixture_to_csv(csv_data_path,pie_retest_csv_path,csv_path_output):

    

    df_count = pd.read_csv(pie_retest_csv_path)
    input_total_count= max(df_count['TOTAL'])
    data1 = pd.read_csv(csv_data_path)
    df = pd.DataFrame(data1)
    
    f_csv = open(csv_path_output,'w',encoding='utf-8')
    csv_writer = csv.writer(f_csv)
    row_count = len(df['Date'])
    if row_count == 0:

        csv_writer.writerow(['Fixture ID','*****','*****','*****','*****','*****','*****'])
        csv_writer.writerow(['Input Qty',str(input_total_count),'*****','*****','*****','*****','*****'])
        csv_writer.writerow(['Retest Item','Qty', 'Retest rate','Slot ID','UUT S/N','Measured Value','[LSL;USL]'])
        f_csv.close()
        return


    data0 = pd.read_csv('/tmp/CPK_Log/temp/yield_rate_param.csv')
    df0 = pd.DataFrame(data0)
    
    for groupName, groupDf in df.groupby(by='Station ID'): #'Station ID'

        try:
            tt_list = list(df0.loc[(df0['Station ID'] == groupName), 'Input (TOTAL)'].tolist())   
            if len(tt_list) == 0:
                tt_list.append('0')
        except Exception as e:
            print('error ,', str(e))
            tt_list.append('0')

        csv_writer.writerow(['Fixture ID',str(groupName),'*****','*****','*****','*****','*****'])
        csv_writer.writerow(['Input Qty',str(tt_list[0]),'*****','*****','*****','*****','*****'])
        csv_writer.writerow(['Retest Item','Qty', 'Retest rate','Slot ID','UUT S/N','Measured Value','[LSL;USL]'])
        occurrences = groupDf.groupby('RetestItem').count().reset_index()
        tmp = occurrences.sort_values('SerialNumber', ascending=False)

        item_name_list = tmp['RetestItem'].tolist()[0:5]
        if len(item_name_list)>5:
            item_name_list = item_name_list[0:5]

        # n_count_list = tmp['SerialNumber'].tolist()[0:5]
        # if len(n_count_list)>5:
        #     n_count_list = n_count_list[0:5]

        nn_index = 0
        for item_name in item_name_list:
            n_retest_count = 0
            serial_number_list =[]
            slot_id_list = []
            measured_value_list = []
            limit_range_list = []
            for index,row in groupDf.iterrows():
                if row['RetestItem'] == item_name:
                    serial_number_list.append(str(row['SerialNumber']))
                    slot_id_list.append(str(row['Slot ID']))
                    meas_val = row['Measured Value']
                    if is_number(meas_val):
                        meas_val = round(meas_val, 3)
                    if str(meas_val) == ''  or str(meas_val) == 'nan' or meas_val == None or str(meas_val) == 'NaN':
                        meas_val = ''
                    measured_value_list.append(str(meas_val))
                    limit_range_list.append(str(row['[LSL;USL]']))
                    n_retest_count = n_retest_count +1

            retest_qty = str(n_retest_count)
            if str(tt_list[0]) == '0':
                retest_rate = 0
            else:
                retest_rate = round(float(retest_qty)/float(tt_list[0])*100,2)
            slot_id_str = ';'.join(slot_id_list)
            serial_number_str = ';'.join(serial_number_list)
            measured_value_str = ';'.join(measured_value_list)
            try:
                limit_range_str = str(limit_range_list[0])
                if limit_range_str == 'NaN' or limit_range_str == 'nan':
                    limit_range_str = ''
            except Exception as e:
                print('error limit range',str(e))
                limit_range_str = ''
            csv_writer.writerow([str(item_name),str(retest_qty), str(retest_rate)+'%',slot_id_str,serial_number_str, measured_value_str,limit_range_str])
            nn_index = nn_index + 1

        if nn_index<5:
            for i in range(5-nn_index):
                csv_writer.writerow(['','', '','', '','',''])

        csv_writer.writerow(['','', '','', '','',''])

    f_csv.close()




def run(n):
    while True:
        try:
            print("wait for retest plot client ...")
            zmqMsg = socket.recv()
            socket.send(b'retest_plot_sendback')
            if len(zmqMsg)>0:
                keyMsg = zmqMsg.decode('utf-8')
                print("message from retest plot client:", keyMsg)
                msg =keyMsg.split("$$")
                if len(msg)>3:
                    if msg[0] == 'retest_plot':
                        all_csv_path = msg[1]
                        retest_csv_path = msg[2]
                        pie_retest_csv_path = msg[3]
                        fail_csv_path = '/tmp/CPK_Log/retest/.fail_csv.csv'
                        header_item_path = '/tmp/CPK_Log/retest/.header_info_csv.csv'

                        print('>generateRetestCSV start')
                        generateRetestCSV(all_csv_path,retest_csv_path,pie_retest_csv_path,fail_csv_path,header_item_path)
                        print('>generateRetestCSV finished')

                        title = 'Pareto Chart for Top 5 Retest'
                        color = 'steelblue'
                        pareto_plot(retest_csv_path, color, title, x='RetestItem', y='SerialNumber', show_pct_y=False,saveas="/tmp/CPK_Log/retest/retest_pareto.png")
                        print('>pareto_plot Pareto Chart for Top 5 Retest finished')
                        
                        title = 'Pareto Chart for Top 5 Fail'
                        color = 'pink'
                        pareto_plot(fail_csv_path, color, title, x='FailItem', y='SerialNumber', show_pct_y=False,saveas="/tmp/CPK_Log/retest/fail_pareto.png")
                        print('>pareto_plot Pareto Chart for Top 5 Fail finished')

                        # pie_retest_plot(pie_retest_csv_path,'/tmp/CPK_Log/retest/retest_pie.png')
                        yield_donut(pie_retest_csv_path,'/tmp/CPK_Log/retest/retest_pie.png')
                        print('>yield_donut finished')

                        summary_retest_path_output = '/tmp/CPK_Log/retest/.summary_retest.csv'
                        summary_retest_csv(retest_csv_path,header_item_path,summary_retest_path_output)
                        print('>summary_retest_csv finished')
                        daily_retest_summary_plot(summary_retest_path_output,'/tmp/CPK_Log/retest/daily_all_retest_summary.png','/tmp/CPK_Log/retest/daily_retest_summary.png')
                        print('>daily_retest_summary_plot finished')

                        retest_vs_station_id_path_output = '/tmp/CPK_Log/retest/.retest_vs_station_id.csv'
                        keyword = ['Station ID','Slot ID']
                        retest_vs_station_slot_id_csv(retest_csv_path,header_item_path,keyword,retest_vs_station_id_path_output)
                        print('>retest_vs_station_slot_id_csv finished')
                        title_name = 'Retest rate vs Station ID & Slot ID'
                        retest_vs_plot(retest_vs_station_id_path_output,title_name,pie_retest_csv_path,'/tmp/CPK_Log/retest/retest_vs_station_id.png',False)
                        print('>retest_vs_plot Retest rate vs Station ID & Slot ID finished')

                        retest_vs_version_path_output = '/tmp/CPK_Log/retest/.retest_vs_version.csv'
                        keyword = 'Version'
                        retest_vs_Version_csv(retest_csv_path,header_item_path,keyword,retest_vs_version_path_output)
                        print('>retest_vs_Version_csv finished')
                        title_name = 'Retest rate vs SW version'
                        retest_vs_plot(retest_vs_version_path_output,title_name,pie_retest_csv_path,'/tmp/CPK_Log/retest/retest_vs_version.png',True)
                        print('>retest_vs_plot Retest rate vs SW version finished')

                        retest_top_5_path = '/tmp/CPK_Log/retest/retest_item_overall.csv'
                        retest_top_5_to_csv(retest_csv_path,pie_retest_csv_path,retest_top_5_path)
                        print('>retest_top_5_to_csv finished')

                        fail_top_5_path = '/tmp/CPK_Log/retest/fail_item_overall.csv'
                        fail_top_5_to_csv(fail_csv_path,pie_retest_csv_path,fail_top_5_path)
                        print('>fail_top_5_to_csv finished')

                        retest_breakdown_path = '/tmp/CPK_Log/retest/retest_breakdown_fixture.csv'
                        retest_breakdown_by_fixture_to_csv(retest_csv_path,pie_retest_csv_path,retest_breakdown_path)
                        print('>retest_breakdown_by_fixture_to_csv finished')

                        filelogname = '/tmp/CPK_Log/retest/.retest_plot.txt'
                        with open(filelogname, 'w') as file_object:
                            file_object.write("Finished,retest plot is finished")
                            print('>all done retest plot and exit.')
                            return


            else:
                time.sleep(0.05)
        except Exception as e:
            print('error retest plot rate:',e)
            filelogname = '/tmp/CPK_Log/retest/.retest_plot.txt'
            with open(filelogname, 'w') as file_object:
                file_object.write("Finished,retest plot report error: " + str(e))

if __name__ == '__main__':
    # run(0)
    retest_vs_version_path_output = '/tmp/CPK_Log/retest/.retest_vs_version.csv'
    title_name = 'Retest rate vs SW version'
    pie_retest_csv_path = '/tmp/CPK_Log/retest/.pie_retest.csv'

    retest_csv_path = '/tmp/CPK_Log/retest/.retest_csv.csv'
    title = 'Pareto Chart for Top 5 Retest'
    color = 'steelblue'

    pareto_plot(retest_csv_path, color, title, x='RetestItem', y='SerialNumber', show_pct_y=False,saveas="/tmp/CPK_Log/retest/retest_pareto.png")

    # retest_vs_plot(retest_vs_version_path_output,title_name,pie_retest_csv_path,'/tmp/CPK_Log/retest/retest_vs_version.png',True)

    # summary_retest_path_output = '/tmp/CPK_Log/retest/.summary_retest.csv'
    # daily_retest_summary_plot(summary_retest_path_output,'/tmp/CPK_Log/retest/daily_all_retest_summary.png','/tmp/CPK_Log/retest/daily_retest_summary.png')
    # print('>daily_retest_summary_plot finished')

    
    retest_vs_station_id_path_output = '/tmp/CPK_Log/retest/.retest_vs_station_id.csv'
    header_item_path = '/tmp/CPK_Log/retest/.header_info_csv.csv'
    # keyword = ['Station ID','Slot ID']
    # retest_vs_station_slot_id_csv(retest_csv_path,header_item_path,keyword,retest_vs_station_id_path_output)
    # print('>retest_vs_station_slot_id_csv finished')
    title_name = 'Retest rate vs Station ID & Slot ID'
    # retest_vs_plot(retest_vs_station_id_path_output,title_name,pie_retest_csv_path,'/tmp/CPK_Log/retest/retest_vs_station_id.png',False)
    # print('>retest_vs_plot Retest rate vs Station ID & Slot ID finished')


# for count,customer in enumerate(df["Supplier"].unique().tolist()):
#     savename = customer+" Pareto.png"
#     print(savename)
#     pareto_plot(df, x='Reason', y='Supplier', customer=customer,show_pct_y=False,saveas=savename)
