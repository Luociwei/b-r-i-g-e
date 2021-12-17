# -*- coding: utf-8 -*-

import matplotlib.pyplot as plt
#%matplotlib inline  #not sure what this line does
import matplotlib.cm as cm
import pandas as pd
#import seaborn as sns
import csv
import textwrap

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

def pareto_plot(df, title, x=None, y=None, customer = None, show_pct_y=False, pct_format='{0:.0%}',saveas = None):
    plt.style.use("seaborn")
    # if customer != None:
    #     df = df[df['Supplier'].str.match(customer)]  # omits data not from supplier
    #     title = customer + " Nonconformities by Cause"
    occurrences = df.groupby('RetestItem').count().reset_index()
    # print(df.head())
    ylabel = "Frequency of Occurrence"
    tmp = occurrences.sort_values(y, ascending=False)
    if len(x)>5:
        x = tmp[x].tolist()[0:5]
    else:
        x = tmp[x].tolist()
    if len(y)>5:
        y = tmp[y].tolist()[0:5]
    else:
        y = tmp[y].tolist()
    x = [str(x[i]) + '\n(' + str(y[i]) + ')' for i in range(min(len(x),len(y)))]
    # print('===1====')
    # print(x)
    # print(y)
    # print('===2====')
    #x = tmp[x].values
    #y = tmp[y].values
    
    # at this point, x should be an ordered list of x axis categories
    # and y should be the number of occurrences
    #weights = y / y.sum()

    weights = []
    colorList = []
    for count in y:
        weights.append(count/sum(y))
    for count in weights:
        colorList.append(count+(1-max(weights)))
    print(weights)
    print(colorList)
    cumsum = []
    for counter,percent in enumerate(weights):
        cumsum.append(sum(weights[:counter+1]))
    fig, ax1 = plt.subplots()
    my_cmap = cm.get_cmap("Blues")
    ax1.bar(x, y,color=my_cmap(colorList))
    #ax1.set_xlabel(xlabel)
    ax1.set_ylabel(ylabel)
    if len(y)==0:
        ax1.set_ylim([0,1])
    else:
        ax1.set_ylim([0,max(y)+1])

    ax2 = ax1.twinx()
    ax2.plot(x, cumsum, '-s',color = "black")#, alpha=0.5)
    ax2.set_ylabel('', color='purple')
    ax2.tick_params('y')#, colors='purple') #right y axis label color
    ax2.set_ylim([0,1.05])
    ax2.grid(alpha = 0)
    
    # vals = ax2.get_yticks()
    # label_format = '{:,.0%}'
    # xx =[label_format.format(x) for x in vals]
    # ax2.set_yticklabels(xx)

    # hide y-labels on right side
    if not show_pct_y:
        ax2.set_yticks([])
    formatted_weights = [pct_format.format(x) for x in cumsum]
    bbox_props = dict(boxstyle="round,pad=0.5", fc="w", ec="0", lw=2)
    for i, txt in enumerate(formatted_weights):
        ax2.text(x[i], cumsum[i],txt, verticalalignment="center",bbox=bbox_props)    
    plt.title(title,fontsize = 14)
    
    plt.tight_layout()
    # plt.show()
    if saveas != None:
        fig.savefig(saveas, dpi=200)



def generateRetestCSV(all_csv_path,retest_csv_path):
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
            # return e
        header_df =df[0:2]
        # print('header_df before--->', header_df)
        data_df = df[2:]
        # print('data_df before--->', data_df)
        # print('csv data row number before remove SN empty--->', len(data_df.values.tolist()))
        data_df=data_df[~data_df['SerialNumber'].isin([''])]#Remove SN Empty
        # print('csv data row number after remove SN empty--->', len(data_df.values.tolist()))

        # print('csv data row number before remove fail--->', len(data_df.values.tolist()))
        total_sn = list((data_df['SerialNumber'].values.tolist()))
        # print('total_sn:',len(total_sn))

        pass_df=data_df[data_df['Test Pass/Fail Status'].isin(['PASS'])]
        # print('pass_df:',len(pass_df))
        overall_pass_sn = list(set(list((pass_df['SerialNumber'].values.tolist()))))
        # print('pass_sn:',len(overall_pass_sn))
        # print('--->>>',data_df['SerialNumber'])
        fail_df=data_df[data_df['Test Pass/Fail Status'].isin(['FAIL'])]
        overall_fail_sn = list(set(list((fail_df['SerialNumber'].values.tolist()))))

        # print('fail_df:',len(fail_df),len(overall_fail_sn))
        total_retest_sn = [z for z in overall_fail_sn if z in overall_pass_sn]  #在list2列表中而不在list1列表中

        f_csv = open(retest_csv_path,'w',encoding='utf-8')
        csv_writer = csv.writer(f_csv)
        csv_writer.writerow(['Date','SerialNumber','RetestItem'])
        for retest_sn in total_retest_sn:
            if retest_sn !='':
                start_time_l = list(data_df.loc[ data_df['SerialNumber'] == retest_sn, 'StartTime'].tolist())
                first_test_time = min(start_time_l)
                fail_list = list(data_df.loc[ data_df['StartTime'].isin([first_test_time]) & (data_df['SerialNumber'] == retest_sn), 'List of Failing Tests'].tolist())
                # print('fail_list:',retest_sn, fail_list[0])
                fail_list_first_item = fail_list[0].split(';',1)[0]
                csv_writer.writerow([first_test_time,retest_sn,checkItemName(fail_list_first_item,5,13)])
        f_csv.close()

excel_file = '/Users/RyanGao/Downloads/ParetoChart-master-2/SampleData1.csv'
csv_all_path = '/Users/RyanGao/Desktop/loadFile/20200714/iPad_data/J517_P1_various.csv' # '/Users/RyanGao/Desktop/loadFile/20200714/iPad_data/test_data_fail.csv'
generateRetestCSV(csv_all_path,excel_file)
df = pd.read_csv(excel_file)
pareto_plot(df, 'Pareto Chart - Retest Items',x='RetestItem', y='SerialNumber', show_pct_y=False,saveas="/Users/RyanGao/Downloads/ParetoChart-master-2/retest_pareto_plot.png")

# for count,customer in enumerate(df["Supplier"].unique().tolist()):
#     savename = customer+" Pareto.png"
#     print(savename)
#     pareto_plot(df, x='Reason', y='Supplier', customer=customer,show_pct_y=False,saveas=savename)