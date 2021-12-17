# coding=utf-8
# -*- coding: utf-8 -*-

import sys
import os
import datetime
from functools import partial
from pytz import timezone
import pytz
import pandas as pd

BASE_DIR=os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0,BASE_DIR+'../site-packages/')

import platform

import subprocess

def checkOSVersion():
    ret = subprocess.Popen("sw_vers | awk 'NR==2 {print $2}'",shell=True,stdout=subprocess.PIPE)
    out,err = ret.communicate()
    out = str(out, encoding = "utf-8")
    out.replace("\n","")
    listVersion = list(map(lambda x:int(x),out.split(".")))
    
    #11.2.3
    print("Check ============{}".format(listVersion))
    if listVersion[0] >=11:
        return 1
    else:
        return 0

print('import Cocoa...')
try:
    import Cocoa, struct
    print(Cocoa.__file__)
except Exception as e:
    print(e)
try: 
    from  Cocoa import NSAppleEventDescriptor as NSAED
    
except Exception as e:
    print('import NSAppleEventDescriptor error')
#print('import Cocoa finished')

# int literal/constant, like in C
INT = lambda s: struct.unpack('>i', s)[0]
intchrs = partial (struct.pack, '>i')

# based on, basically, reverse engineering the headers. Can't find them linked
# anywhere :S
kCurrentProcess            = 2
kAutoGenerateReturnID      = -1
kAnyTransactionID          = 0
kASSubroutineEvent         = INT ('psbr'.encode())
typeProcessSerialNumber    = INT ('psn '.encode())
keyASSubroutineName        = INT ('snam'.encode())
typeAppleScript            = INT ('ascr'.encode())
keyDirectObject            = INT ('----'.encode())
typeIEEE64BitFloatingPoint = INT ('doub'.encode())

# Cocoa/Carbon ProcessSerialNumber struct - { UInt32, UInt32 }
struct_ProcessSerialNumber = 'II'

class OSAScript(object):
    def __init__(self, source):
        self.script = Cocoa.NSAppleScript.alloc().initWithSource_ (source)

    def __getattr__(self, evtname):
        return partial (self.execute_event, evtname)

    def execute_event(self, evtname, *args):
        procdes = NSAED.descriptorWithDescriptorType_bytes_length_ (
                        typeProcessSerialNumber,
                        struct.pack (struct_ProcessSerialNumber, 0, kCurrentProcess),
                        struct.calcsize (struct_ProcessSerialNumber))

        evt = NSAED.appleEventWithEventClass_eventID_targetDescriptor_returnID_transactionID_ (
                    typeAppleScript, kASSubroutineEvent, procdes,
                    kAutoGenerateReturnID, kAnyTransactionID)

        updateDescriptorKeywords (evt,
            [(keyASSubroutineName, evtname),
             (keyDirectObject,     args)])

        out, err = self.script.executeAppleEvent_error_ (evt, None)
        
        if err is not None:
            raise OSAError (err)

        return convertDescriptor (out)

class OSAError(Exception):
    """ Raised when there's an error returned by an OSA script """

# map NSA.E.D. descriptor types for value descriptors to the corresponding
# value accessors, or conversion functions where appropriate
descTypeToConverter = {
    INT ('bool'.encode()): NSAED.booleanValue,
    INT ('enum'.encode()): NSAED.enumCodeValue,
    INT ('long'.encode()): NSAED.int32Value,
    INT ('utxt'.encode()): NSAED.stringValue,
    INT ('doub'.encode()): lambda d: struct.unpack('d', d.data())[0],

    # NSA.E.D. listDescriptors are 1-based
    INT ('list'.encode()): lambda d: [ convertDescriptor (d.descriptorAtIndex_ (i))
                              for i in xrange (1, d.numberOfItems() + 1) ],

    INT ('reco'.encode()): lambda d: { kwd: d.descriptorForKeyword_ (kwd)
                              for i in xrange (1, d.numberOfItems() + 1)
                              for kwd in [d.keywordForDescriptorAtIndex_ (i)] }
}

typeToDescConstructor = [
    (bool,          NSAED.descriptorWithBoolean_),
    (int,           NSAED.descriptorWithInt32_),
    (str,    NSAED.descriptorWithString_),

    (float,         lambda v:
        NSAED.descriptorWithDescriptorType_bytes_length_ (
            typeIEEE64BitFloatingPoint, struct.pack ('d', v), struct.calcsize ('d'))),

    ((tuple, list), lambda v: seqToListDescriptor (v)),
    (dict,          lambda v: dictToRecordDescriptor (v))
]

def convertDescriptor (d):
    conv = descTypeToConverter.get (d.descriptorType())
    return conv and conv (d)

def toDescriptor (v):
    for typ, construct in typeToDescConstructor:
        if isinstance (v, typ):
            return construct (v)
    return NSAED.nullDescriptor()

def seqToListDescriptor (v):
    ld = NSAED.listDescriptor()
    for i, val in enumerate (v):
        # NSA.E.D. listDescriptors are 1-based
        ld.insertDescriptor_atIndex_ (toDescriptor (val), i + 1)
    return ld

def updateDescriptorKeywords (rd, items):
    for prop, val in items:
        rd.setDescriptor_forKeyword_ (toDescriptor (val), prop)

def dictToRecordDescriptor (v):
    rd = NSAED.recordDescriptor()
    updateDescriptorKeywords (rd, v.iteritems())
    return rd

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

def get_pst_time():
    date_format=  '%m/%d/%Y %H:%M:%S' #'%m-%d%Y_%H_%M_%S_%Z'
    date = datetime.datetime.now(tz=pytz.utc)
    date = date.astimezone(timezone('US/Pacific'))
    pstDateTime=date.strftime(date_format)
    return pstDateTime

def create_keynote(title_msg):
    # print(os.path.realpath(__file__))    #current file path
    # print(os.path.dirname(os.path.realpath(__file__)))  #current file dir
    # print(os.path.basename(os.path.realpath(__file__))) #current file name
    # os.path.dirname(os.path.realpath(__file__))+'/keynote_mode'
    # current_dir = os.path.dirname(os.path.realpath(__file__))
    # keynote_lib_path = current_dir+'/keynote_mode'
    # print(keynote_lib_path)
    # # sys.path.append(keynote_lib_path)
    # sys.path.insert(0,current_dir+'/')
    # # cmd = 'cd '+current_dir+';export PYTHONPATH='+keynote_lib_path
    # cmd = 'cd '+current_dir+'/'
    # print('generate cmd--->',cmd)
    # print(os.system(cmd))
    # print('python import ---->OSAScript')
    keynote = OSAScript(source)


    doc = keynote.newPresentation(u'White') 
    slide = create_Slide_title(doc,keynote)
    keynote.addLog(doc,slide,'/tmp/CPK_Log/retest/.apple_log_black.png')
    keynote.addText(doc, slide, 1, title_msg)
    keynote.addStyledTextItem3(doc,slide,'Date: '+str(get_pst_time()))
    
    return doc,keynote

def add_overall_pic(doc,keynote,path):
    slide0 = keynote.createSlideWithFullBlank(doc)
    keynote.insertSlideWithFullImage(doc,slide0,path) #  insert overall pic


def add_one_pic(doc,keynote,pic_path,message):
    slide = keynote.createSlide(doc, u'Photo')
    keynote.addImage(doc, slide, pic_path, 600, 500, 460, 610)
    keynote.addPresenterNotes(doc,slide,message)



def add_fail_pic(doc,keynote,pic_path,item_name,description_info,root_cause_info,plan_info,bmFilterInfo,csv_path):
    
    slide = keynote.createSlideWithImage(doc, pic_path)
    item_name = checkItemName(item_name,70)

    #if bmFilterInfo is not None:
    #    keynote.addTableDataForFilter(doc, slide, csv_path, len(bmFilterInfo) + 1, 2, 36, 12,checkOSVersion())
    
    keynote.addStyledTextItemTitle(doc,slide,item_name)
    
    keynote.addStyledTextItem1(doc,slide,description_info)
    
    keynote.addStyledTextItem2(doc,slide,root_cause_info)
    
    keynote.addStyledTextItem3(doc,slide,plan_info)
    

def add_fail_multi_pic_in_one_slide(doc, keynote,fail_pic_path,file_table,pic_count_in_slide):

    if int(pic_count_in_slide) == 2:
        for file_tb in file_table:

            quotient = int(len(file_tb)/pic_count_in_slide)
            remainder = int(len(file_tb)%pic_count_in_slide)

            for i in range(quotient):
                item_name = file_tb[i]
                tmp_tag = file_tb[i].split(' ')
                if len(tmp_tag)>2:

                    if '@' in tmp_tag[1]:
                        tmp_coverage = tmp_tag[1].split('@')
                        item_name = str(tmp_tag[0])+' '+str(tmp_coverage[0])
                    elif '-' in tmp_tag[1]:
                        tmp_coverage = tmp_tag[1].split('-')
                        item_name = str(tmp_tag[0])+' '+str(tmp_coverage[0])
                    else:
                        item_name = str(tmp_tag[0])+' '+str(tmp_tag[1])

                slide = keynote.createSlide(doc, u"Blank")
                keynote.addSlideTextTitle(doc,slide,item_name,100, 10)

                sub_pic_path = fail_pic_path +'/'+file_tb[i]+'.png'
                if os.path.exists(sub_pic_path):
                    keynote.addImage(doc, slide, sub_pic_path, 910, 780, 10, 140)

                sub_pic_path = fail_pic_path +'/'+file_tb[i+1]+'.png'
                if os.path.exists(sub_pic_path):
                    keynote.addImage(doc, slide, sub_pic_path, 910, 780, 950, 140)

            if remainder !=0:
                item_name = file_tb[-remainder]
                tmp_tag = file_tb[-remainder].split(' ')
                if len(tmp_tag)>2:
                    if '@' in tmp_tag[1]:
                        tmp_coverage = tmp_tag[1].split('@')
                        item_name = str(tmp_tag[0])+' '+str(tmp_coverage[0])
                    elif '-' in tmp_tag[1]:
                        tmp_coverage = tmp_tag[1].split('-')
                        item_name = str(tmp_tag[0])+' '+str(tmp_coverage[0])
                    else:
                        item_name = str(tmp_tag[0])+' '+str(tmp_tag[1])

                slide = keynote.createSlide(doc, u"Blank")
                keynote.addSlideTextTitle(doc,slide,item_name,100, 10)
                for i in range(remainder):
                    sub_pic_path = fail_pic_path +'/'+file_tb[i-remainder]+'.png'
                    if os.path.exists(sub_pic_path):
                        keynote.addImage(doc, slide, sub_pic_path, 910, 780, 10, 140)




    elif int(pic_count_in_slide) == 4:
        print('pic_count_in_slide:',pic_count_in_slide)
        for file_tb in file_table:

            quotient = int(len(file_tb)/pic_count_in_slide)
            remainder = int(len(file_tb)%pic_count_in_slide)
            print('quotient,remainder :',quotient,remainder)
            for i in range(quotient):
                item_name = file_tb[i]
                tmp_tag = file_tb[i].split(' ')
                if len(tmp_tag)>2:
                    if '@' in tmp_tag[1]:
                        tmp_coverage = tmp_tag[1].split('@')
                        item_name = str(tmp_tag[0])+' '+str(tmp_coverage[0])
                    elif '-' in tmp_tag[1]:
                        tmp_coverage = tmp_tag[1].split('-')
                        item_name = str(tmp_tag[0])+' '+str(tmp_coverage[0])
                    else:
                        item_name = str(tmp_tag[0])+' '+str(tmp_tag[1])

                slide = keynote.createSlide(doc, u"Blank")
                keynote.addSlideTextTitle(doc,slide,item_name,100, 10)

                sub_pic_path = fail_pic_path +'/'+file_tb[i]+'.png'
                if os.path.exists(sub_pic_path):
                    keynote.addImage(doc, slide, sub_pic_path, 560, 480, 130, 100)

                sub_pic_path = fail_pic_path +'/'+file_tb[i+1]+'.png'
                if os.path.exists(sub_pic_path):
                    keynote.addImage(doc, slide, sub_pic_path, 560, 480, 1000, 100)

                sub_pic_path = fail_pic_path +'/'+file_tb[i+2]+'.png'
                if os.path.exists(sub_pic_path):
                    keynote.addImage(doc, slide, sub_pic_path, 560, 480, 130, 580)

                sub_pic_path = fail_pic_path +'/'+file_tb[i+3]+'.png'
                if os.path.exists(sub_pic_path):
                    keynote.addImage(doc, slide, sub_pic_path, 560, 480, 1000, 580)

            if remainder !=0:
                item_name = file_tb[-remainder]
                tmp_tag = file_tb[-remainder].split(' ')
                if len(tmp_tag)>2:
                    if '@' in tmp_tag[1]:
                        tmp_coverage = tmp_tag[1].split('@')
                        item_name = str(tmp_tag[0])+' '+str(tmp_coverage[0])
                    elif '-' in tmp_tag[1]:
                        tmp_coverage = tmp_tag[1].split('-')
                        item_name = str(tmp_tag[0])+' '+str(tmp_coverage[0])
                    else:
                        item_name = str(tmp_tag[0])+' '+str(tmp_tag[1])

                slide = keynote.createSlide(doc, u"Blank")
                keynote.addSlideTextTitle(doc,slide,item_name,100, 10)
                for i in range(remainder):
                    sub_pic_path = fail_pic_path +'/'+file_tb[i-remainder]+'.png'
                    if os.path.exists(sub_pic_path):
                        if i==0:
                            keynote.addImage(doc, slide, sub_pic_path, 560, 480, 130, 100)
                        if i==1:
                            keynote.addImage(doc, slide, sub_pic_path, 560, 480, 1000, 100)
                        if i==2:
                            keynote.addImage(doc, slide, sub_pic_path, 560, 480, 130, 580)
                        if i==3:
                            keynote.addImage(doc, slide, sub_pic_path, 560, 480, 1000, 580)

        

    elif int(pic_count_in_slide) == 6:

        for file_tb in file_table:

            quotient = int(len(file_tb)/pic_count_in_slide)
            remainder = int(len(file_tb)%pic_count_in_slide)

            for i in range(quotient):
                item_name = file_tb[i]
                tmp_tag = file_tb[i].split(' ')
                if len(tmp_tag)>2:
                    if '@' in tmp_tag[1]:
                        tmp_coverage = tmp_tag[1].split('@')
                        item_name = str(tmp_tag[0])+' '+str(tmp_coverage[0])
                    elif '-' in tmp_tag[1]:
                        tmp_coverage = tmp_tag[1].split('-')
                        item_name = str(tmp_tag[0])+' '+str(tmp_coverage[0])
                    else:
                        item_name = str(tmp_tag[0])+' '+str(tmp_tag[1])

                slide = keynote.createSlide(doc, u"Blank")
                keynote.addSlideTextTitle(doc,slide,item_name,100, 10)

                sub_pic_path = fail_pic_path +'/'+file_tb[i]+'.png'
                if os.path.exists(sub_pic_path):
                    keynote.addImage(doc, slide, sub_pic_path, 560, 480, 30, 100)

                sub_pic_path = fail_pic_path +'/'+file_tb[i+1]+'.png'
                if os.path.exists(sub_pic_path):
                    keynote.addImage(doc, slide, sub_pic_path, 560, 480, 620, 100)

                sub_pic_path = fail_pic_path +'/'+file_tb[i+2]+'.png'
                if os.path.exists(sub_pic_path):
                    keynote.addImage(doc, slide, sub_pic_path, 560, 480, 1240, 100)

                sub_pic_path = fail_pic_path +'/'+file_tb[i+3]+'.png'
                if os.path.exists(sub_pic_path):
                    keynote.addImage(doc, slide, sub_pic_path, 560, 480, 30, 580)

                sub_pic_path = fail_pic_path +'/'+file_tb[i+4]+'.png'
                if os.path.exists(sub_pic_path):
                    keynote.addImage(doc, slide, sub_pic_path, 560, 480, 620, 580)

                sub_pic_path = fail_pic_path +'/'+file_tb[i+5]+'.png'
                if os.path.exists(sub_pic_path):
                    keynote.addImage(doc, slide, sub_pic_path, 560, 480, 1240, 580)

            if remainder !=0:
                item_name = file_tb[-remainder]
                tmp_tag = file_tb[-remainder].split(' ')
                if len(tmp_tag)>2:
                    if '@' in tmp_tag[1]:
                        tmp_coverage = tmp_tag[1].split('@')
                        item_name = str(tmp_tag[0])+' '+str(tmp_coverage[0])
                    elif '-' in tmp_tag[1]:
                        tmp_coverage = tmp_tag[1].split('-')
                        item_name = str(tmp_tag[0])+' '+str(tmp_coverage[0])
                    else:
                        item_name = str(tmp_tag[0])+' '+str(tmp_tag[1])

                slide = keynote.createSlide(doc, u"Blank")
                keynote.addSlideTextTitle(doc,slide,item_name,100, 10)

                for i in range(remainder):
                    sub_pic_path = fail_pic_path +'/'+file_tb[i-remainder]+'.png'
                    if os.path.exists(sub_pic_path):
                        if i==0:
                            keynote.addImage(doc, slide, sub_pic_path, 560, 480, 30, 100)
                        if i==1:
                            keynote.addImage(doc, slide, sub_pic_path, 560, 480, 620, 100)
                        if i==2:
                            keynote.addImage(doc, slide, sub_pic_path, 560, 480, 1240, 100)
                        if i==3:
                            keynote.addImage(doc, slide, sub_pic_path, 560, 480, 30, 580)
                        if i==4:
                            keynote.addImage(doc, slide, sub_pic_path, 560, 480, 620, 580)
                        if i==5:
                            keynote.addImage(doc, slide, sub_pic_path, 560, 480, 1240, 580)

        
    
    elif int(pic_count_in_slide) == 8:

        for file_tb in file_table:

            quotient = int(len(file_tb)/pic_count_in_slide)
            remainder = int(len(file_tb)%pic_count_in_slide)

            for i in range(quotient):
                item_name = file_tb[i]
                tmp_tag = file_tb[i].split(' ')
                if len(tmp_tag)>2:
                    if '@' in tmp_tag[1]:
                        tmp_coverage = tmp_tag[1].split('@')
                        item_name = str(tmp_tag[0])+' '+str(tmp_coverage[0])
                    elif '-' in tmp_tag[1]:
                        tmp_coverage = tmp_tag[1].split('-')
                        item_name = str(tmp_tag[0])+' '+str(tmp_coverage[0])
                    else:
                        item_name = str(tmp_tag[0])+' '+str(tmp_tag[1])

                slide = keynote.createSlide(doc, u"Blank")
                keynote.addSlideTextTitle(doc,slide,item_name,100, 10)

                sub_pic_path = fail_pic_path +'/'+file_tb[i]+'.png'
                if os.path.exists(sub_pic_path):
                    keynote.addImage(doc, slide, sub_pic_path, 460, 390, 10, 100)

                sub_pic_path = fail_pic_path +'/'+file_tb[i+1]+'.png'
                if os.path.exists(sub_pic_path):
                    keynote.addImage(doc, slide, sub_pic_path, 460, 390, 470, 100)

                sub_pic_path = fail_pic_path +'/'+file_tb[i+2]+'.png'
                if os.path.exists(sub_pic_path):
                    keynote.addImage(doc, slide, sub_pic_path, 460, 390, 940, 100)

                sub_pic_path = fail_pic_path +'/'+file_tb[i+3]+'.png'
                if os.path.exists(sub_pic_path):
                    keynote.addImage(doc, slide, sub_pic_path, 460, 390, 1410, 100)

                sub_pic_path = fail_pic_path +'/'+file_tb[i+4]+'.png'
                if os.path.exists(sub_pic_path):
                    keynote.addImage(doc, slide, sub_pic_path, 460, 390, 10, 580)

                sub_pic_path = fail_pic_path +'/'+file_tb[i+5]+'.png'
                if os.path.exists(sub_pic_path):
                    keynote.addImage(doc, slide, sub_pic_path, 460, 390, 470, 580)

                sub_pic_path = fail_pic_path +'/'+file_tb[i+6]+'.png'
                if os.path.exists(sub_pic_path):
                    keynote.addImage(doc, slide, sub_pic_path, 460, 390, 940, 580)

                sub_pic_path = fail_pic_path +'/'+file_tb[i+7]+'.png'
                if os.path.exists(sub_pic_path):
                    keynote.addImage(doc, slide, sub_pic_path, 460, 390, 1410, 580)


            if remainder !=0:
                item_name = file_tb[-remainder]
                tmp_tag = file_tb[-remainder].split(' ')
                if len(tmp_tag)>2:
                    if '@' in tmp_tag[1]:
                        tmp_coverage = tmp_tag[1].split('@')
                        item_name = str(tmp_tag[0])+' '+str(tmp_coverage[0])
                    elif '-' in tmp_tag[1]:
                        tmp_coverage = tmp_tag[1].split('-')
                        item_name = str(tmp_tag[0])+' '+str(tmp_coverage[0])
                    else:
                        item_name = str(tmp_tag[0])+' '+str(tmp_tag[1])

                slide = keynote.createSlide(doc, u"Blank")
                keynote.addSlideTextTitle(doc,slide,item_name,100, 10)

                for i in range(remainder):
                    sub_pic_path = fail_pic_path +'/'+file_tb[i-remainder]+'.png'
                    if os.path.exists(sub_pic_path):
                        if i==0:
                            keynote.addImage(doc, slide, sub_pic_path, 460, 390, 10, 100)
                        if i==1:
                            keynote.addImage(doc, slide, sub_pic_path, 460, 390, 470, 100)
                        if i==2:
                            keynote.addImage(doc, slide, sub_pic_path, 460, 390, 940, 100)
                        if i==3:
                            keynote.addImage(doc, slide, sub_pic_path, 460, 390, 1410, 100)
                        if i==4:
                            keynote.addImage(doc, slide, sub_pic_path, 460, 390, 10, 580)
                        if i==5:
                            keynote.addImage(doc, slide, sub_pic_path, 460, 390, 470, 580)
                        if i==6:
                            keynote.addImage(doc, slide, sub_pic_path, 460, 390, 940, 580)
                        if i==7:
                            keynote.addImage(doc, slide, sub_pic_path, 460, 390, 1410, 580)
        


def add_build_summary_overview(doc,keynote,tab_path,pie_path):
    slide = keynote.createSlide(doc, u"Blank")
    keynote.addSlideTextTitle(doc,slide,"Build Summary Overview",100, 10)

    # if os.path.exists(pie_path):
    #     keynote.addImage(doc, slide, pie_path, 600, 500, 460, 600)
    if os.path.exists(tab_path):
        data1= pd.read_csv(tab_path)
        df = pd.DataFrame(data1)
        rowCount = int(df.iloc[:,0].size)+1
        columnCount = int(df.columns.size)
        print('>.rowCount:',rowCount)
        print('columnCount:',columnCount)

        n_reference = 12
        rowPage = int(rowCount/n_reference)
        row_2 = rowCount%n_reference

        if rowCount<=n_reference+2:
            keynote.addTableData(doc, slide,tab_path,rowCount,columnCount,70,25,checkOSVersion())

        else:
            for i in range(rowPage):
                if i ==0:
                    new_data = data1.loc[i*n_reference:i*n_reference+n_reference-1]
                    new_path = '/tmp/CPK_Log/retest/.yield_rate_param_tmp.csv'
                    new_data.to_csv(new_path,index=False,sep=',')
                    keynote.addTableData(doc, slide,new_path,n_reference+1,columnCount,70,25,checkOSVersion())
                else:
                    slide = keynote.createSlide(doc, u"Blank")
                    keynote.addSlideTextTitle(doc,slide,"Build Summary Overview",100, 10)

                    new_data = data1.loc[i*n_reference:i*n_reference+n_reference-1]
                    new_path = '/tmp/CPK_Log/retest/.yield_rate_param_tmp.csv'
                    new_data.to_csv(new_path,index=False,sep=',')

                    keynote.addTableData(doc, slide,new_path,n_reference+1,columnCount,70,25,checkOSVersion())
                
            if row_2>0:
                new_data = data1.loc[rowPage*n_reference+1:rowPage*n_reference+row_2]
                print('>new_data',new_data.iloc[:,0].size)
                if int(new_data.iloc[:,0].size)>0:
                    slide = keynote.createSlide(doc, u"Blank")
                    keynote.addSlideTextTitle(doc,slide,"Build Summary Overview",100, 10)
                    new_path = '/tmp/CPK_Log/retest/.yield_rate_param_tmp.csv'
                    new_data.to_csv(new_path,index=False,sep=',')
                    keynote.addTableData(doc, slide,new_path,row_2+1,columnCount,70,25,checkOSVersion())
        

def add_build_yield_pie(doc,keynote,pie_path):
    slide = keynote.createSlide(doc, u"Blank")
    keynote.addSlideTextTitle(doc,slide,"Build Yield Chart",100, 10)
    if os.path.exists(pie_path):
        keynote.addImage(doc, slide, pie_path, 960, 860, 400, 150)
def add_build_yield_pie_keynote(doc,keynote,headers,rownames,datas):
    print("11111111 " + str(keynote))
    slide = keynote.createSlide(doc, u"Blank")
    print("11111111 ?-----?" + str(keynote))
    keynote.addSlideTextTitle(doc,slide,"Build Yield Chart",100, 10)
    print("11111111 ?????" + str(keynote))
    keynote.addYieldChart(doc,slide,headers,rownames,datas)
    print("222222"+ str(keynote) )
    

def build_failures_retest_pareto(doc,keynote,retest_pareto_path,fail_pareto_path):
    slide = keynote.createSlide(doc, u"Blank")
    keynote.addSlideTextTitle(doc,slide,"Build Failures and Retest Pareto",100, 10)
    if os.path.exists(retest_pareto_path):
        keynote.addImage(doc, slide, retest_pareto_path, 960, 860, 125, 130)

    if os.path.exists(fail_pareto_path):
        slide = keynote.createSlide(doc, u"Blank")
        keynote.addSlideTextTitle(doc,slide,"Build Failures and Retest Pareto",100, 10)
        keynote.addImage(doc, slide, fail_pareto_path, 960, 860, 125, 130)

def build_failures_retest_pareto1_keynote(doc,keynote,headers,rownames,datas,tableName):
    slide = keynote.createSlide(doc, u"Blank")
    keynote.addSlideTextTitle(doc,slide,"Build {}".format(tableName),100, 10)
    keynote.addLineChart(doc,slide,headers,rownames,datas)

def build_failures_retest_pareto1_keynote_numbers(doc,keynote,headers,rownames,datas,tableName):
    slide = keynote.createSlide(doc, u"Blank")
    keynote.addSlideTextTitle(doc,slide,"Build {}".format(tableName),100, 10)
    keynote.CreateTableByNumbers(rownames,headers,datas,slide,doc,"line",checkOSVersion())
    keynote.SetLineChartOutlook2() #keynote.SetTopChartOutlook()
def CloseNumbers(keynote):
    for i in range(0,5):
        keynote.CloseNumbers()
def CloseKeynotes(keynote):
    for i in range(0,5):
        keynote.CloseKeynotes()

def build_failures_retest_top10_keynote(doc,keynote,headers,rownames,datas,isClick = 1,tableName=""):
    slide = keynote.createSlide(doc, u"Blank")
    keynote.addSlideTextTitle(doc,slide,"Build {}".format(tableName),100, 10)
    keynote.addTopChart(doc,slide,headers,rownames,datas,isClick)

def build_failures_retest_top10_keynote_numbers(doc,keynote,headers,rownames,datas,isClick = 1,tableName=""):
    slide = keynote.createSlide(doc, u"Blank")
    keynote.addSlideTextTitle(doc,slide,"Build {}".format(tableName),100, 10)
    keynote.CreateTableByNumbers(rownames,headers,datas,slide,doc,"base",checkOSVersion())#headers, datas, nSlid, nDoc
    keynote.SetTopChartOutlook2()

def build_summary_all_retest_rates_keynote(doc,keynote,headers,rownames,datas,tableName):
    slide = keynote.createSlide(doc, u"Blank")
    keynote.addSlideTextTitle(doc,slide,"Build {}".format(tableName),100, 10)
    keynote.addLineChart(doc,slide,headers,rownames,datas)

def build_summary_all_retest_rates_keynote_numbers(doc,keynote,headers,rownames,datas,tableName):
    slide = keynote.createSlide(doc, u"Blank")
    keynote.addSlideTextTitle(doc,slide,"Build {}".format(tableName),100, 10)
    keynote.CreateTableByNumbers(rownames,headers,datas,slide,doc,"line",checkOSVersion())
    keynote.SetLineChartOutlook2()
    


def build_summary_all_retest_rates(doc,keynote,daily_all_retest_path):
    slide = keynote.createSlide(doc, u"Blank")
    keynote.addSlideTextTitle(doc,slide,"Build Summary : Daily All Retest Rate",100, 10)
    if os.path.exists(daily_all_retest_path):
        keynote.addImage(doc, slide, daily_all_retest_path, 960, 860, 125, 130)
        for i in range(50):
            new_path = daily_all_retest_path.replace('.png','')+str(i+1) + '.png'
            if os.path.exists(new_path):
                slide = keynote.createSlide(doc, u"Blank")
                keynote.addSlideTextTitle(doc,slide,"Build Summary : Daily All Retest Rate",100, 10)
                keynote.addImage(doc, slide, new_path, 960, 860, 125, 130)
            else:
                break
def build_summary_retest_rates_keynote(doc,keynote,headers,rownames,datas,tableName):
    slide = keynote.createSlide(doc, u"Blank")
    keynote.addSlideTextTitle(doc,slide,"Build {}".format(tableName),100, 10)
    print("build_summary_retest_rates_keynote In here ?")
    keynote.addLineChart(doc,slide,headers,rownames,datas)
def build_summary_retest_rates_keynote_numbers(doc,keynote,headers,rownames,datas,tableName):
    slide = keynote.createSlide(doc, u"Blank")
    keynote.addSlideTextTitle(doc,slide,"Build {}".format(tableName),100, 10)
    print("build_summary_retest_rates_keynote In here ?")
    #keynote.addLineChart(doc,slide,headers,rownames,datas)
    keynote.CreateTableByNumbers(rownames,headers,datas,slide,doc,"line",checkOSVersion())
    keynote.SetLineChartOutlook2()
   
def build_summary_retest_rates(doc,keynote,daily_retest_path,retest_vs_station_path,retest_vs_version_path):
    slide = keynote.createSlide(doc, u"Blank")
    keynote.addSlideTextTitle(doc,slide,"Build Summary : Daily Retest Rate",100, 10)
    if os.path.exists(daily_retest_path):
        keynote.addImage(doc, slide, daily_retest_path, 960, 860, 125, 130)

        for i in range(50):
            new_path = daily_retest_path.replace('.png','')+str(i+1) + '.png'
            if os.path.exists(new_path):
                slide = keynote.createSlide(doc, u"Blank")
                keynote.addSlideTextTitle(doc,slide,"Build Summary : Daily Retest Rate",100, 10)
                keynote.addImage(doc, slide, new_path, 960, 860, 125, 130)
            else:
                break



    slide = keynote.createSlide(doc, u"Blank")
    keynote.addSlideTextTitle(doc,slide,"Build Summary : Station ID & Slot ID Retest Rate",100, 10)
    if os.path.exists(retest_vs_station_path):
        keynote.addImage(doc, slide, retest_vs_station_path, 960, 860, 125, 130)
        for i in range(50):
            new_path = retest_vs_station_path.replace('.png','')+str(i+1) + '.png'
            if os.path.exists(new_path):
                slide = keynote.createSlide(doc, u"Blank")
                keynote.addSlideTextTitle(doc,slide,"Build Summary : Station ID & Slot ID Retest Rate",100, 10)
                keynote.addImage(doc, slide, new_path, 960, 860, 125, 130)
            else:
                break



    slide = keynote.createSlide(doc, u"Blank")
    keynote.addSlideTextTitle(doc,slide,"Build Summary : SW Version Retest Rate",100, 10)
    if os.path.exists(retest_vs_version_path):
        keynote.addImage(doc, slide, retest_vs_version_path, 960, 880, 125, 130)

        for i in range(50):
            new_path = retest_vs_version_path.replace('.png','')+str(i+1) + '.png'
            if os.path.exists(new_path):
                slide = keynote.createSlide(doc, u"Blank")
                keynote.addSlideTextTitle(doc,slide,"Build Summary : SW Version Retest Rate",100, 10)
                keynote.addImage(doc, slide, new_path, 960, 860, 125, 130)
            else:
                break

def top_5_fail_and_retest(doc,keynote,top_5fail_path,top_5retest_path):
    slide = keynote.createSlide(doc, u"Blank")
    keynote.addSlideTextTitle(doc,slide,"Top Fail and Retest Trends",100, 10)
    if os.path.exists(top_5fail_path):
        data1= pd.read_csv(top_5fail_path)
        df = pd.DataFrame(data1)
        rowCount = int(df.iloc[:,0].size)+1
        columnCount = int(df.columns.size)
        print('>>top_5fail rowCount:',rowCount)
        print('>>top_5fail columnCount:',columnCount)
        keynote.addTableData2(doc, slide, top_5fail_path, rowCount, columnCount, 50, 20, 150, 200, "Row Data Table",checkOSVersion())

    if os.path.exists(top_5retest_path):
        data1= pd.read_csv(top_5retest_path)
        df = pd.DataFrame(data1)
        rowCount = int(df.iloc[:,0].size)+1
        columnCount = int(df.columns.size)
        print('>>top_5retest rowCount:',rowCount)
        print('>>top_5retest columnCount:',columnCount)
        keynote.addTableData2(doc, slide, top_5retest_path, rowCount, columnCount, 50, 20, 150, 650, "Row Data Table2",checkOSVersion())

def fixture_retest_breakdown(doc,keynote,reset_breakdown_path):

    if os.path.exists(reset_breakdown_path):
        data1= pd.read_csv(reset_breakdown_path)
        df = pd.DataFrame(data1)
        rowCount = int(df.iloc[:,0].size)+1
        columnCount = int(df.columns.size)
        print('>>rowCount:',rowCount)
        print('>>columnCount:',columnCount)
        slide = None

        n_table = int(rowCount/9)
        if n_table == 0:
            slide = keynote.createSlide(doc, u"Blank")
            keynote.addSlideTextTitle(doc,slide,"Fixture wise Retest Breakdown (Top 5)",100, 10)
            keynote.addTableData3(doc, slide, reset_breakdown_path, rowCount, columnCount, 30, 20, 150, 200, "Row Data Table", 1, rowCount,checkOSVersion())
        else:
            for i in range(n_table):
                if i%2 == 0:
                    slide = keynote.createSlide(doc, u"Blank")
                    keynote.addSlideTextTitle(doc,slide,"Fixture wise Retest Breakdown",100, 10)
                    keynote.addTableData3(doc, slide, reset_breakdown_path, rowCount, columnCount, 50, 20, 150, 170, "Row Data Table", int(i*9+1), int(i*9+8),checkOSVersion())
                else:
                    if slide != None:
                        keynote.addTableData3(doc, slide, reset_breakdown_path, rowCount, columnCount, 50, 20, 150, 620, "Row Data Table"+str(i+2), int(i*9+1), int(i*9+8),checkOSVersion())


def max_min_cpk_technology(doc,keynote,cpk_path):
    slide = keynote.createSlide(doc, u"Blank")
    keynote.addSlideTextTitle(doc,slide,"Cpk Technology Wise",100, 10)
    if os.path.exists(cpk_path):
        data1= pd.read_csv(cpk_path)
        df = pd.DataFrame(data1)
        rowCount = int(df.iloc[:,0].size)+1
        columnCount = int(df.columns.size)
        
        n_reference = 15
        rowPage = int(rowCount/n_reference)
        row_2 = rowCount%n_reference

        if rowCount<=n_reference+2:
            keynote.addTableData(doc, slide,cpk_path,rowCount,columnCount,50,20,checkOSVersion())

        else:
            for i in range(rowPage):
                if i ==0:
                    new_data = data1.loc[i*n_reference:i*n_reference+n_reference]
                    new_path = '/tmp/CPK_Log/retest/.cpk_range.csv'
                    new_data.to_csv(new_path,index=False,sep=',')

                    keynote.addTableData(doc, slide,new_path,n_reference+2,columnCount,50,20,checkOSVersion())
                else:
                    slide = keynote.createSlide(doc, u"Blank")
                    keynote.addSlideTextTitle(doc,slide,"Cpk Technology Wise",100, 10)

                    new_data = data1.loc[i*n_reference+1:i*n_reference+n_reference]
                    new_path = '/tmp/CPK_Log/retest/.cpk_range.csv'
                    new_data.to_csv(new_path,index=False,sep=',')

                    keynote.addTableData(doc, slide,new_path,n_reference+1,columnCount,50,20,checkOSVersion())
                
            if row_2>0:
                new_data = data1.loc[rowPage*n_reference+1:rowPage*n_reference+row_2]
                print('>>new_data',new_data.iloc[:,0].size)
                if int(new_data.iloc[:,0].size)>0:
                    slide = keynote.createSlide(doc, u"Blank")
                    keynote.addSlideTextTitle(doc,slide,"Cpk Technology Wise",100, 10)
                    
                    new_path = '/tmp/CPK_Log/retest/.cpk_range.csv'
                    new_data.to_csv(new_path,index=False,sep=',')

                    keynote.addTableData(doc, slide,new_path,row_2+1,columnCount,50,20,checkOSVersion())



def create_abnormal_distribution(doc,keynote,msg_txt):
    slide = create_Slide_title(doc,keynote)
    keynote.addText(doc, slide, 1, msg_txt)


def create_Slide_title(doc,keynote):   
    m_slide = False
    try:
        slide = keynote.createSlide(doc, u'Title - Center')
        return slide
    except Exception as e:
        m_slide = True
        print('1.>slide Title - Center error',e)

    if m_slide: 
        try:
            m_slide = False
            slide = keynote.createSlide(doc, u'Title - Centre')
            return slide
        except Exception as e:
            m_slide = True
            print('2.>>slide Title - Centre error',e)
    if m_slide:
        try:
            m_slide = False
            slide = keynote.createSlideWithFullBlank(doc)
            return slide
        except Exception as e:
            m_slide = True
            print('3.>>>slide Title - Centre error',e)
    return None





def save_keynote(doc,keynote,save_keynote_path):
    keynote.finalize(doc)
    keynote.savePresentation(doc,save_keynote_path)
    # keynote.closePresentation(doc)
    # keynote.deleteAllSlides(doc)
    print("<<<save keynote file finished>>>")


source = '''on newPresentation(themeName)

    tell application "Keynote"
        activate
        -- FIXME: Make this selectable?
        set targetWidth to 1880
        set targetHeight to 1080

        set props to {document theme:theme (themeName as string), width:targetWidth, height:targetHeight}

        set thisDocument to make new document with properties props
    end tell
    CloseKeynotes() of me

    tell application "Keynote"
        activate
        -- FIXME: Make this selectable?
        set targetWidth to 1880
        set targetHeight to 1080

        set props to {document theme:theme (themeName as string), width:targetWidth, height:targetHeight}

        set thisDocument to make new document with properties props
        return id of thisDocument
    end tell
end newPresentation

on openPresentation(posixPath)
    tell application "Keynote"

        open posixPath
    end tell
end openPresentation


on savePresentation(docId, posixPath)
    tell application "Keynote"  
        set theDocument to document id docId
        save theDocument in POSIX file posixPath
        delete theDocument
        --open posixPath 
    end tell
end savePresentation  


on closePresentation(docId)
    tell application "Keynote"  
        set theDocument to document id docId
        close theDocument
    end tell
end closePresentation    


on createSlide(docId, masterSlideName)
    tell application "Keynote"
        tell document id docId
            set thisSlide to make new slide with properties {base slide:master slide masterSlideName}
        end tell
        return slide number of thisSlide
    end tell
end createSlide

on createSlide_ex(docId, masterSlideName, title_msg, filepath)
    tell application "Keynote"
        tell document id docId
            set thisSlide to make new slide with properties {base slide:master slide masterSlideName}
            tell thisSlide
                set thisShape to make new shape with properties {position:{0,0},width:1888,height:1080}
                tell thisShape
                -- set type size
                    set the size of its object text to 112
                end tell
            end tell
            set theImage to filepath as POSIX file
            tell thisSlide
                make new image with properties {file:theImage, width:70, height:70, position:{40, 30}}
            end tell
        end tell
        return slide number of thisSlide
    end tell
end createSlide_ex

on deleteAllSlides(docId)
    tell application "Keynote"
        tell document id docId to delete every slide
    end tell
end deleteAllSlides

on finalize(docId)
    tell application "Keynote"
        tell document id docId to delete slide 1
    end tell
end finalize

on themeMasters(docId)
    --    tell application "Keynote" to get the name of every master slide of thisDocument
    tell application "Keynote"
        set names to the name of every master slide of document id docId
        return names
    end tell
end themeMasters

on addImage_not_use(docId, slideIndex, n, filepath)
  tell application "Keynote"
    tell slide slideIndex of document id docId
        -- TO REPLACE A PLACEHOLDER OR EXISTING IMAGE:
        set thisPlaceholderImageItem to image n
        -- change the value of the “file name” property of the image to be an HFS file reference to the replacement image file
        set macPath to POSIX file filepath as Unicode text
        set file name of thisPlaceholderImageItem to ¬
            alias macPath
    end tell
  end tell
end addImage_not_use

on addImage(docId, slideIndex, filepath, pic_width, pic_height, pos_x, pos_y)
    tell application "Keynote"
        tell slide slideIndex of document id docId
            set theImage to filepath as POSIX file
            make new image with properties {file:theImage, width:pic_width, height:pic_height, position:{pos_x, pos_y}}
        end tell
    end tell
end addImage




on addTitle(docId, slideIndex, thisSlideTitle)
    tell application "Keynote"
        tell slide slideIndex of document id docId
            set the object text of the default title item to thisSlideTitle
        end tell
    end tell
end addTitle

on addBody(docId, slideIndex, thisSlideBody)
    tell application "Keynote"
        tell slide slideIndex of document id docId
            set the object text of the default body item to thisSlideBody
        end tell
    end tell
end addTitle

on addPresenterNotes(docId, slideIndex, theNotes)
    tell application "Keynote"
        tell slide slideIndex of document id docId
            set presenter notes to theNotes
        end tell
    end tell
end addPresenterNotes

on addText(docId, slideIndex, itemIndex, theText)
  tell application "Keynote"
    tell slide slideIndex of document id docId
        set thisPlaceholderItem to text item itemIndex
        set object text of thisPlaceholderItem to theText
    end tell
  end tell
end addText

on addText_ex(docId, slideIndex, itemIndex, theText)
    tell application "Keynote"
        tell slide slideIndex of document id docId
            set thisTextItem to make new text item with properties {object text:theText}
            tell thisTextItem
                -- set type size
                set the size of its object text to 112
                -- set typeface
                set the font of its object text to "Helvetica"
                -- adjust its vertical positon
                set its position to {230, 500}
                -- style the text
                repeat with i from 1 to my min(the length of [], the length of theText)
                    set thisRGBColorValue to item i of []
                    set the color of character i of object text to thisRGBColorValue
                end repeat
            end tell
        end tell
    end tell
end addText_ex

on addStyledTextItemAsMedia(docId, slideIndex, mediaIndex, theText, theStyleList, theSize, theFont)
    tell application "Keynote"
        tell slide slideIndex of document id docId
            set thisImage to image mediaIndex
            -- copy {position:position of thisImage, width:width of thisImage, height:height of thisImage} to info
            copy position of thisImage to thePosition
            delete thisImage
        end tell        
    end tell    
    my addStyledTextItem(docId, slideIndex, theText, theStyleList, thePosition, theSize, theFont)
end addStyledTextItemAsMedia


on addStyledTextItem(docId, slideIndex, theText, thePosition, theSize, theFont)
    tell application "Keynote"
        tell slide slideIndex of document id docId
            set thisTextItem to make new text item with properties {object text:theText}
            
            tell thisTextItem
                -- set type size
                set the size of its object text to theSize
                -- set typeface
                set the font of its object text to theFont
                -- adjust its vertical positon
                set its position to thePosition
                -- style the text
                repeat with i from 1 to the length of theText
                    set thisRGBColorValue to my generateRandomRGBColorValue()
                    set the color of character i of object text to thisRGBColorValue
                end repeat
            end tell
        end tell
    end tell
end addStyledTextItem

on generateRandomRGBColorValue()
    set RedValue to 0
    set GreenValue to 0
    set BlueValue to 0
    return {RedValue, GreenValue, BlueValue}
end generateRandomRGBColorValue

on createSlideWithFullImage(docId, filepath)
    tell application "Keynote"
        tell document id docId
            set theImage to filepath as POSIX file
            --tell slideIndex
            set thisSlide to make new slide with properties {base slide:master slide "Blank"}
            tell thisSlide
                make new image with properties {file:theImage, width:1024, height:768, position:{0, 0}}
            end tell
            --set thisSlide to make new slide with properties {base slide:master slide masterSlideName}
        end tell
        return slide number of thisSlide
    end tell
end createSlideWithFullImage

on createSlideWithImage(docId, filepath)
    tell application "Keynote"
        tell document id docId
            set theImage to filepath as POSIX file
            --tell slideIndex
            set thisSlide to make new slide with properties {base slide:master slide "Blank"}
            tell thisSlide
                make new image with properties {file:theImage, width:1224, height:684, position:{200, 70}}
            end tell
            --set thisSlide to make new slide with properties {base slide:master slide masterSlideName}
        end tell
        return slide number of thisSlide
    end tell
end createSlideWithImage

on createSlideWithFullBlank(docId)
    tell application "Keynote"
        tell document id docId
            --tell slideIndex
            set thisSlide to make new slide with properties {base slide:master slide "Blank"}
            --set thisSlide to make new slide with properties {base slide:master slide masterSlideName}
        end tell
        return slide number of thisSlide
    end tell
end createSlideWithFullBlank

on insertSlideWithFullImage(docId, slideIndex, filepath)
    tell application "Keynote"
        tell slide slideIndex of document id docId
            set theImage to filepath as POSIX file
            make new image with properties {file:theImage, width:1800, height:1080, position:{30, 0}}
        end tell
    end tell
end insertSlideWithFullImage

on addSlideTextTitle(docId, slideIndex, txt, x_pos, y_pos)
    addStyledTextItem(docId, slideIndex, txt, {x_pos, y_pos}, 40, "Helvetica")
end addSlideTextTitle


on addStyledTextTitle(docId,slideIndex,txt)
   addStyledTextItem(docId, slideIndex,txt,{200, 350}, 85, "Helvetica")
end addStyledTextTitle

on addStyledTextItemTitle(docId,slideIndex,txt)
   addStyledTextItem(docId, slideIndex,txt, {130, 10}, 35, "Helvetica")
end addStyledTextItemTitle

on addStyledTextItem1(docId,slideIndex,txt)
   addStyledTextItem(docId, slideIndex,txt, {100, 810}, 35, "Helvetica")
end addStyledTextItem1

on addStyledTextItem2(docId,slideIndex,txt)
   addStyledTextItem(docId, slideIndex,txt, {100, 870}, 35, "Helvetica")
end addStyledTextItem2

on addStyledTextItem3(docId,slideIndex,txt)
   addStyledTextItem(docId, slideIndex,txt, {100, 930}, 35, "Helvetica")
end addStyledTextItem3

on min(a, b)
    if a < b then
        set x to a
    else
        set x to b
    end if
    return x
end min

on addLog(docId, slideIndex, filepath)
    tell application "Keynote"
        tell slide slideIndex of document id docId
            set theImage to filepath as POSIX file
            make new image with properties {file:theImage, width:100, height:100, position:{50, 20}}
        end tell
    end tell
end addLog

-----table----
on toevennumber(input)
    return (input + (input mod 2))
end toevennumber

on toevennumbercheckversion(input,isOldversion)
    set ou to (input + (input mod 2))
    if ou is 10 and isOldversion is 0 then
        set ou to ou + 2
    end if
    return ou
end toevennumbercheckversion

on readTabSeparatedValuesFile(thisTSVFile)
    try
        set dataBlob to (every paragraph of (read thisTSVFile))
        set the tabledata to {}
        set AppleScript's text item delimiters to ","
        repeat with i from 1 to the count of dataBlob
            set the end of the tabledata to (every text item of (item i of dataBlob))
        end repeat
        set AppleScript's text item delimiters to ""
        return tabledata
    on error errorMessage number errorNumber
        set AppleScript's text item delimiters to ""
        error errorMessage number errorNumber
    end try
end readTabSeparatedValuesFile

on addTableData(docId, slideIndex, filepath, rowCount, columnCount, tab_height, txt_size,isOldVersion)
    tell application "Keynote"
        tell slide slideIndex of document id docId
            set tabledata to my readTabSeparatedValuesFile(filepath)
            if rowCount < 2 then
                set rowCount to 2
            end if

            if isOldVersion is 0 then
                set rowCount to toevennumber(rowCount) of me
            end if

            set thisTable to make new table with properties {row count:rowCount, column count:columnCount, name:"Row Data Table", header row count:1, header column count:0}
            tell thisTable
                set rowIndex to 1
                set columnIndex to 1
                set font size of every cell to txt_size
                set the height of every row to tab_height
                set the rowCellCount to count of cells of row 2
                repeat with i from 1 to count of the tabledata -- get a data set from the data set list
                    set thisRowData to item i of the tabledata
                    tell row (i)
                        -- iterate the data set, populating row cells from left to right
                        repeat with q from 1 to the count of thisRowData
                            tell cell (q)
                                set value to item q of thisRowData
                                set alignment to center
                                set vertical alignment to center
                            end tell
                        end repeat
                    end tell
                end repeat
            end tell
            
        end tell
    end tell
    
end addTableData

on addTableData2(docId, slideIndex, filepath, rowCount, columnCount, tab_height, txt_size, pos_x, pos_y, tab_name,isOldVersion)
    tell application "Keynote"
        tell slide slideIndex of document id docId
            set tabledata to my readTabSeparatedValuesFile(filepath)
            if rowCount < 3 then
                set rowCount to 3
            end if

            if isOldVersion is 0 then
                set rowCount to toevennumber(rowCount) of me
            end if


            set thisTable to make new table with properties {row count:rowCount, column count:columnCount, name:tab_name, header row count:2, header column count:0, position:{pos_x, pos_y}}
            tell thisTable
                set rowIndex to 1
                set columnIndex to 1
                set font size of every cell to txt_size
                set the height of every row to tab_height
                set the rowCellCount to count of cells of row 2
                repeat with i from 1 to count of the tabledata -- get a data set from the data set list
                    set thisRowData to item i of the tabledata
                    tell row (i)
                        -- iterate the data set, populating row cells from left to right
                        repeat with q from 1 to the count of thisRowData
                            tell cell (q)
                                set value to item q of thisRowData
                                set alignment to center
                                set vertical alignment to center
                            end tell
                        end repeat
                    end tell
                end repeat
            end tell
        end tell
    end tell
    
end addTableData2

on addTableData3(docId, slideIndex, filepath, rowCount, columnCount, tab_height, txt_size, pos_x, pos_y, tab_name, row_start, row_end,isOldVersion)
    tell application "Keynote"
        tell slide slideIndex of document id docId
            set tabledata to my readTabSeparatedValuesFileByRow(filepath, row_start, row_end)
            set rowCount to row_end - row_start + 1
            if rowCount < 3 then
                set rowCount to 3
            end if


            if isOldVersion is 0 then
                set rowCount to toevennumber(rowCount) of me
            end if



            set thisTable to make new table with properties {row count:rowCount, column count:columnCount, name:tab_name, header row count:2, header column count:0, position:{pos_x, pos_y}}
            tell thisTable
                set rowIndex to 1
                set columnIndex to 1
                set font size of every cell to txt_size
                set the height of every row to tab_height
                set the rowCellCount to count of cells of row 2
                repeat with i from 1 to count of the tabledata -- get a data set from the data set list
                    set thisRowData to item i of the tabledata
                    tell row (i)
                        -- iterate the data set, populating row cells from left to right
                        repeat with q from 1 to the count of thisRowData
                            tell cell (q)
                                set value to item q of thisRowData
                                set alignment to center
                                set vertical alignment to center
                            end tell
                        end repeat
                    end tell
                end repeat
            end tell
        end tell
    end tell
    
end addTableData3

on readTabSeparatedValuesFileByRow(thisTSVFile, row_start, row_end)
    try
        set dataBlob to (every paragraph of (read thisTSVFile))
        if row_end > the (count of dataBlob) then
            set row_end to the (count of dataBlob) - 1
        end if
        set the tabledata to {}
        set AppleScript's text item delimiters to ","
        repeat with i from row_start to row_end
            set the end of the tabledata to (every text item of (item i of dataBlob))
        end repeat
        set AppleScript's text item delimiters to ""
        return tabledata
    on error errorMessage number errorNumber
        set AppleScript's text item delimiters to ""
        error errorMessage number errorNumber
    end try
end readTabSeparatedValuesFileByRow

--Added By Vito
on SetTopChartOutlook()
    tell application "System Events"
        tell process "Keynote" -- 告诉 app
            set myname to the name of front window

            click radio button "Chart" of radio group 1 of window 1
            
            
            set isLegend to get value of checkbox "Legend" of scroll area 1 of window 1
            if isLegend is 0 then
                click checkbox "Legend" of scroll area 1 of window 1
            end if
            
            --set small font
            repeat with n from 1 to 4
                click button 1 of group 1 of scroll area 1 of window 1
            end repeat
            
            
            
            
            
            
            --to Axis page
            click radio button "Axis" of radio group 1 of window 1
            
            click radio button "Value (Y)" of radio group 1 of scroll area 1 of window 1




            click pop up button 4 of scroll area 1 of window 1
            delay 0.1
            try
                tell pop up button 4 of scroll area 1 of window 1
                    set {xPosition, yPosition} to position
                    set {xSize, ySize} to size
                end tell
                -- modify offsets if hot spot is not centered:
                click at {xPosition + (xSize div 2), yPosition + (ySize div 2) - ySize}
            end try
            
            
            
            


            
            
            click radio button "Category (X)" of radio group 1 of scroll area 1 of window 1
            
            
            set needclick to the value of UI element 11 of scroll area 1 of window 1
            if needclick is 0 then
                
                click UI element 11 of scroll area 1 of window 1
            end if
            delay 0.1
            click pop up button 3 of scroll area 1 of window 1
            delay 0.1
            try
                tell pop up button 3 of scroll area 1 of window 1
                    set {xPosition, yPosition} to position
                    set {xSize, ySize} to size
                end tell
                -- modify offsets if hot spot is not centered:
                click at {xPosition + (xSize div 2), yPosition + (ySize div 2) + 2 * ySize}
            end try
            
            click pop up button 2 of scroll area 1 of window 1
            try
                tell pop up button 2 of scroll area 1 of window 1
                    set {xPosition, yPosition} to position
                    set {xSize, ySize} to size
                end tell
                -- modify offsets if hot spot is not centered:
                click at {xPosition + (xSize div 2), yPosition + (ySize div 2) - ySize}
            end try
            
            
            
            
            --to Series page
            click radio button "Series" of radio group 1 of window 1
            
            click pop up button 1 of scroll area 1 of window 1
            delay 0.1
            try
                tell pop up button 1 of scroll area 1 of window 1
                    set {xPosition, yPosition} to position
                    set {xSize, ySize} to size
                end tell
                -- modify offsets if hot spot is not centered:
                click at {xPosition + (xSize div 2), yPosition + (ySize div 2) + ySize}
            end try
            
        end tell
    end tell
end SetTopChartOutlook


on SetLineChartOutlook()
    tell application "System Events"
        tell process "Keynote" -- 告诉 app
            
            click radio button "Chart" of radio group 1 of window 1
            --check Legend
            set isLegend to get value of checkbox "Legend" of scroll area 1 of window 1
            if isLegend is 0 then
                click checkbox "Legend" of scroll area 1 of window 1
            end if
            
            --set small font
            repeat with n from 1 to 4
                click button 1 of group 1 of scroll area 1 of window 1
            end repeat
            
            --to Axis page
            click radio button "Axis" of radio group 1 of window 1
            
            click radio button "Value (Y)" of radio group 1 of scroll area 1 of window 1

            --delay 0.1
            --click pop up button 2 of scroll area 1 of window 1
            --delay 0.1
            --try
            --    tell pop up button 2 of scroll area 1 of window 1
            --        set {xPosition, yPosition} to position
            --        set {xSize, ySize} to size
            --    end tell
            --    -- modify offsets if hot spot is not centered:
            --    click at {xPosition + (xSize div 2), yPosition + (ySize div 2) + 2*ySize}
            --end try


            click pop up button 4 of scroll area 1 of window 1
            delay 0.1
            try
                tell pop up button 4 of scroll area 1 of window 1
                    set {xPosition, yPosition} to position
                    set {xSize, ySize} to size
                end tell
                -- modify offsets if hot spot is not centered:
                click at {xPosition + (xSize div 2), yPosition + (ySize div 2) - ySize}
            end try
            
            
            
            
            
            click radio button "Category (X)" of radio group 1 of scroll area 1 of window 1
            
            
            set needclick to the value of UI element 10 of scroll area 1 of window 1
            
            if needclick is 0 then
                click UI element 10 of scroll area 1 of window 1
            end if
            
            click pop up button 3 of scroll area 1 of window 1
            delay 0.1
            try
                tell pop up button 3 of scroll area 1 of window 1
                    set {xPosition, yPosition} to position
                    set {xSize, ySize} to size
                end tell
                -- modify offsets if hot spot is not centered:
                click at {xPosition + (xSize div 2), yPosition + (ySize div 2) + 2 * ySize}
            end try
            
            click pop up button 2 of scroll area 1 of window 1
            try
                tell pop up button 2 of scroll area 1 of window 1
                    set {xPosition, yPosition} to position
                    set {xSize, ySize} to size
                end tell
                -- modify offsets if hot spot is not centered:
                click at {xPosition + (xSize div 2), yPosition + (ySize div 2) - ySize}
            end try
            
            
            
            
            --to Series page
            click radio button "Series" of radio group 1 of window 1
            
            click pop up button 1 of scroll area 1 of window 1
            delay 0.1
            try
                tell pop up button 1 of scroll area 1 of window 1
                    set {xPosition, yPosition} to position
                    set {xSize, ySize} to size
                end tell
                -- modify offsets if hot spot is not centered:
                click at {xPosition + (xSize div 2), yPosition + (ySize div 2) + ySize}
            end try
            
            click pop up button 3 of scroll area 1 of window 1
            delay 0.1
            try
                tell pop up button 3 of scroll area 1 of window 1
                    set {xPosition, yPosition} to position
                    set {xSize, ySize} to size
                end tell
                -- modify offsets if hot spot is not centered:
                click at {xPosition + (xSize div 2), yPosition + (ySize div 2) - (4 * ySize)}
            end try
            
            click pop up button 4 of scroll area 1 of window 1
            delay 0.1
            try
                tell pop up button 4 of scroll area 1 of window 1
                    set {xPosition, yPosition} to position
                    set {xSize, ySize} to size
                end tell
                -- modify offsets if hot spot is not centered:
                click at {xPosition + (xSize div 2), yPosition + (ySize div 2) + ySize}
            end try


            
            
            
        end tell
    end tell
end SetLineChartOutlook


--for number call
on SetTopChartOutlook2()
    tell application "System Events"
        tell process "Keynote" -- 告诉 app
            set myname to the name of front window

            click radio button "Chart" of radio group 1 of window 1
            
            
            set isLegend to get value of checkbox "Legend" of scroll area 1 of window 1
            if isLegend is 0 then
                click checkbox "Legend" of scroll area 1 of window 1
            end if
            
            --set small font
            repeat with n from 1 to 4
                click button 2 of group 1 of scroll area 1 of window 1
            end repeat
            
            
            
            
            
            
            --to Axis page
            click radio button "Axis" of radio group 1 of window 1
            
            click radio button "Value (Y)" of radio group 1 of scroll area 1 of window 1




            click pop up button 4 of scroll area 1 of window 1
            delay 0.1
            try
                tell pop up button 4 of scroll area 1 of window 1
                    set {xPosition, yPosition} to position
                    set {xSize, ySize} to size
                end tell
                -- modify offsets if hot spot is not centered:
                click at {xPosition + (xSize div 2), yPosition + (ySize div 2) - ySize}
            end try
            
            
            
            


            
            
            click radio button "Category (X)" of radio group 1 of scroll area 1 of window 1
            
            
            set needclick to the value of UI element 11 of scroll area 1 of window 1
            if needclick is 0 then
                
                click UI element 11 of scroll area 1 of window 1
            end if
            delay 0.1
            click pop up button 3 of scroll area 1 of window 1
            delay 0.1
            try
                tell pop up button 3 of scroll area 1 of window 1
                    set {xPosition, yPosition} to position
                    set {xSize, ySize} to size
                end tell
                -- modify offsets if hot spot is not centered:
                click at {xPosition + (xSize div 2), yPosition + (ySize div 2) + 2 * ySize}
            end try
            
            click pop up button 2 of scroll area 1 of window 1
            try
                tell pop up button 2 of scroll area 1 of window 1
                    set {xPosition, yPosition} to position
                    set {xSize, ySize} to size
                end tell
                -- modify offsets if hot spot is not centered:
                click at {xPosition + (xSize div 2), yPosition + (ySize div 2) - ySize}
            end try
            
            
            
            
            --to Series page
            click radio button "Series" of radio group 1 of window 1
            
            click pop up button 1 of scroll area 1 of window 1
            delay 0.1
            try
                tell pop up button 1 of scroll area 1 of window 1
                    set {xPosition, yPosition} to position
                    set {xSize, ySize} to size
                end tell
                -- modify offsets if hot spot is not centered:
                click at {xPosition + (xSize div 2), yPosition + (ySize div 2) + ySize}
            end try
            
        end tell
    end tell
end SetTopChartOutlook2


on SetLineChartOutlook2()
    tell application "System Events"
        tell process "Keynote" -- 告诉 app
            activate
            click radio button "Chart" of radio group 1 of window 1
            --check Legend
            set isLegend to get value of checkbox "Legend" of scroll area 1 of window 1
            if isLegend is 0 then
                click checkbox "Legend" of scroll area 1 of window 1
            end if
            
            --set small font
            repeat with n from 1 to 4
                click button 2 of group 1 of scroll area 1 of window 1
            end repeat
            
            --to Axis page
            click radio button "Axis" of radio group 1 of window 1
            
            click radio button "Value (Y)" of radio group 1 of scroll area 1 of window 1

            delay 0.1
            click pop up button 2 of scroll area 1 of window 1
            delay 0.1
            try
                tell pop up button 2 of scroll area 1 of window 1
                    set {xPosition, yPosition} to position
                    set {xSize, ySize} to size
                end tell
                -- modify offsets if hot spot is not centered:
                click at {xPosition + (xSize div 2), yPosition + (ySize div 2) + 1.5*ySize}
            end try


            click pop up button 4 of scroll area 1 of window 1
            delay 0.1
            try
                tell pop up button 4 of scroll area 1 of window 1
                    set {xPosition, yPosition} to position
                    set {xSize, ySize} to size
                end tell
                -- modify offsets if hot spot is not centered:
                click at {xPosition + (xSize div 2), yPosition + (ySize div 2) - ySize}
            end try
            
            
            
            
            
            click radio button "Category (X)" of radio group 1 of scroll area 1 of window 1
            
            
            set needclick to the value of UI element 10 of scroll area 1 of window 1
            
            if needclick is 0 then
                click UI element 10 of scroll area 1 of window 1
            end if
            
            click pop up button 3 of scroll area 1 of window 1
            delay 0.1
            try
                tell pop up button 3 of scroll area 1 of window 1
                    set {xPosition, yPosition} to position
                    set {xSize, ySize} to size
                end tell
                -- modify offsets if hot spot is not centered:
                click at {xPosition + (xSize div 2), yPosition + (ySize div 2) + 2 * ySize}
            end try
            
            click pop up button 2 of scroll area 1 of window 1
            try
                tell pop up button 2 of scroll area 1 of window 1
                    set {xPosition, yPosition} to position
                    set {xSize, ySize} to size
                end tell
                -- modify offsets if hot spot is not centered:
                click at {xPosition + (xSize div 2), yPosition + (ySize div 2) - ySize}
            end try
            
            
            
            
            --to Series page
            click radio button "Series" of radio group 1 of window 1
            
          
            set vur to value of pop up button 2 of scroll area 1 of window 1
            if vur is "None" then
                click pop up button 2 of scroll area 1 of window 1
                delay 0.1
                try
                    tell pop up button 2 of scroll area 1 of window 1
                        set {xPosition, yPosition} to position
                        set {xSize, ySize} to size
                    end tell
                    -- modify offsets if hot spot is not centered:
                    click at {xPosition + (xSize div 2), yPosition + (ySize div 2) +  ySize}
                end try

            end if
            
            
            
 
        end tell
    end tell
end SetLineChartOutlook2 




on SetChartOutlook()
    tell application "System Events"
        tell process "Keynote" -- 告诉 app
            #  set myname to the name of front window
            
            
            repeat with n from 1 to 5
                click button 1 of group 1 of scroll area 1 of window 1
            end repeat
            
            get value of checkbox "Legend" of scroll area 1 of window 1
            --check Legend
            click
            set isLegend to get value of checkbox "Legend" of scroll area 1 of window 1
            if isLegend is 0 then
                click checkbox "Legend" of scroll area 1 of window 1
            end if
            
            --to Wedges page
            click radio button "Wedges" of radio group 1 of window 1
            --set isDataPointNames to get value of checkbox "Data Point Names" of scroll area 1 of window 1
            --if isDataPointNames is 0 then
            --   click checkbox "Data Point Names" of scroll area 1 of window 1
            --end if
            
            set isOnpenSize to the value of UI element 4 of scroll area 1 of window 1
            
            if isOnpenSize is 0 then
                click UI element 4 of scroll area 1 of window 1
            end if
            click button 1 of incrementor 1 of scroll area 1 of window 1
            
            set isValues to get value of checkbox "Values" of scroll area 1 of window 1
            if isValues is 0 then
                click checkbox "Values" of scroll area 1 of window 1
            end if
            
            
            
            set isOnpenDisSize to the value of UI element 16 of scroll area 1 of window 1
            if isOnpenDisSize is 0 then
                click UI element 16 of scroll area 1 of window 1
            end if
            repeat with n from 1 to 6
                click button 1 of incrementor 2 of scroll area 1 of window 1
            end repeat
            
        end tell
    end tell
end SetChartOutlook

on addYieldChart(docId, slideIndex, columnames, rowNames, datas)
    tell application "Keynote"
        activate
        tell slide slideIndex of document id docId
            add chart row names rowNames column names columnames data datas type pie_3d group by chart column
        end tell
    end tell
    delay 2.5
    SetChartOutlook() of me
end addYieldChart

on addLineChart(docId, slideIndex, columnames, rowNames, datas)
    tell application "Keynote"
        tell slide slideIndex of document id docId
            add chart row names columnames column names rowNames data datas type line_2d group by chart row
        end tell
    end tell
    delay 0.5
    SetLineChartOutlook() of me
end addLineChart
on addTopChart(docId, slideIndex, columnames, rowNames, datas, isClick)
    tell application "Keynote"
        tell slide slideIndex of document id docId
            add chart row names columnames column names rowNames data datas type vertical_bar_2d group by chart row
        end tell
    end tell
    delay 0.5
    SetTopChartOutlook() of me
end addTopChart

-- Added By Vito 
-- add numbers functions
on CreateTableByNumbers(rownames, headers, datas, nSlid, nDoc, typeName,isOldVersion)
    createTable(rownames, headers, datas, typeName,isOldVersion) of me
    CloseNumbers() of me
    Moveposition(nSlid, nDoc) of me

end CreateTableByNumbers

on GetRow(datas)
    return the count of item 1 of datas
end GetRow
on RevelList(datas)
    set ListRet to {}
    repeat with i from 1 to the count of item 1 of datas
        repeat with j from 1 to the count of datas
            set the end of ListRet to item i of item j of datas
        end repeat
    end repeat
    
    return ListRet
end RevelList


on createTable(rownames, headers, datas, typeName, isOldVersion)
    tell application "Numbers"
        activate
        set thisDocument to make new document
        tell thisDocument
            tell active sheet
                set rowCount to 1 + (GetRow(datas) of me)
                if isOldVersion is 0 then
                    set rowCount to toevennumbercheckversion(rowCount,isOldVersion) of me
                end if
                set columnCount to 1 + (the count of headers)
                if isOldVersion is 0 then
                    set columnCount to toevennumber(columnCount) of me
                end if
                set thisTable to make new table with properties {row count:rowCount, column count:columnCount}
                tell thisTable
                    set dataTest to RevelList(datas) of me
                    set the width of every column to 36
                    set the height of every row to 24
                    set alignment of every cell to center
                    set vertical alignment of every cell to center
                    
                    
                    
                    --repeat with i from 1 to (1 + (GetRow(datas) of me)) * (1 + (the count of headers))
                    repeat with i from 1 to rowCount * columnCount
                        
                        set nRow to ((i - 1) div (columnCount))
                        set nCol to ((i - 1) mod (columnCount))
                        
                        if nRow > ((GetRow(datas) of me)) then
                            exit repeat
                        end if
                        
                        if nCol < 1 + (the count of headers) then
                            --set the value of cell i to ((nCol as string) & " " & nRow as string) --debug 
                            if nRow is 0 and nCol is not 0 then
                                set the value of cell i to (get item (nCol) of headers)
                            else if nCol is not 0 then
                                set the value of cell i to (get item (nCol + (nRow - 1) * (the count of headers)) of dataTest)
                            else if nCol is 0 and nRow is not 0 then
                                set the value of cell i to (get item (nRow) of rownames)
                            end if
                        end if
                        
                        
                    end repeat
                    
                    --set the selection range to range thisTable
                    --set the selection range to the cell range
                    set the selection range to range (getRange((1 + (GetRow(datas) of me)), (1 + (the count of headers))) of me)
                    
                    --click to generate Chart
                    CreateChat(typeName) of me
                end tell
            end tell
        end tell
        
    end tell
    
end createTable
on createTable1(rownames, headers, datas, typeName,isOldVersion)
    tell application "Numbers"
        activate
        set thisDocument to make new document
        tell thisDocument
            tell active sheet
                set rowCount to 1 + (GetRow(datas) of me)
                if isOldVersion is 0 then
                    set rowCount to toevennumber(rowCount) of me
                end if
                set thisTable to make new table with properties {row count:rowCount, column count:1 + (the count of headers)}
                tell thisTable
                    set dataTest to RevelList(datas) of me
                    set the width of every column to 36
                    set the height of every row to 24
                    set alignment of every cell to center
                    set vertical alignment of every cell to center
                    
                    

                    repeat with i from 1 to (1 + (GetRow(datas) of me)) * (1 + (the count of headers))
                        
                        set nRow to ((i - 1) div (1 + (the count of headers)))
                        set nCol to ((i - 1) mod (1 + (the count of headers)))
                        
                        --set the value of cell i to ((nCol as string) & " " & nRow as string) --debug 
                        if nRow is 0 and nCol is not 0 then
                            set the value of cell i to (get item (nCol) of headers)
                        else if nCol is not 0 then
                            set the value of cell i to (get item (nCol + (nRow - 1) * (the count of headers)) of dataTest)
                        else if nCol is 0 and nRow is not 0 then
                            set the value of cell i to (get item (nRow) of rownames)
                        end if
                        
                    end repeat



                    
                    
                    --set the selection range to range thisTable
                    set the selection range to the cell range
                    
                    --click to generate Chart
                    CreateChat(typeName) of me
                    
                    
                    
                end tell
            end tell
        end tell
        
    end tell
    
end createTable1

on createTableold(rownames, headers, datas, typeName)
    tell application "Numbers"
        activate
        set thisDocument to make new document
        tell thisDocument
            tell active sheet
                set thisTable to make new table with properties {row count:1 + (GetRow(datas) of me), column count:1 + (the count of headers)}
                tell thisTable
                    set dataTest to RevelList(datas) of me
                    set the width of every column to 36
                    set the height of every row to 24
                    set alignment of every cell to center
                    set vertical alignment of every cell to center
                    
                    
                    get dataTest
                    repeat with i from 1 to the count of cells
                        
                        set nRow to ((i - 1) div (1 + (the count of headers)))
                        set nCol to ((i - 1) mod (1 + (the count of headers)))
                        
                        --set the value of cell i to ((nCol as string) & " " & nRow as string) --debug 
                        if nRow is 0 and nCol is not 0 then
                            set the value of cell i to (get item (nCol) of headers)
                        else if nCol is not 0 then
                            set the value of cell i to (get item (nCol + (nRow - 1) * (the count of headers)) of dataTest)
                        else if nCol is 0 and nRow is not 0 then
                            set the value of cell i to (get item (nRow) of rownames)
                        end if
                        
                    end repeat
                    
                    --set the selection range to range thisTable
                    set the selection range to the cell range
                    
                    --click to generate Chart
                    CreateChat(typeName) of me
                    
                    
                    
                end tell
            end tell
        end tell
        
    end tell
    
end createTableold

on CreateChat(typeName)
    tell application "System Events"
        tell process "Numbers" -- 告诉 app
            --click checkbox 1 of group 6 of toolbar 1 of window 1
            set ChartButton to 0
            set isExit to 0
            repeat with windowItem in toolbar 1 of window 1
                set isExit to 0
                set ItemUIs to groups in windowItem as list
                repeat with itemsI in ItemUIs
                    
                    try
                        get value of static text "Chart" of itemsI
                        click checkbox 1 of itemsI
                        set ChartButton to checkbox 1 of itemsI
                        --success 
                        exit repeat
                    end try
                end repeat
                if ChartButton is not 0 then
                    exit repeat
                end if
            end repeat
            
            if ChartButton is not 0 then
                set gain to 8
                if typeName is "line" then
                    set gain to (6.5) * 5
                end if
                
                try
                    tell ChartButton
                        set {xPosition, yPosition} to position
                        set {xSize, ySize} to size
                    end tell
                    -- modify offsets if hot spot is not centered:
                    click at {xPosition + (xSize div 2) - 2 * xSize, yPosition + (ySize div 2) + 4 * (ySize div 2)}
                end try
                try
                    tell ChartButton
                        set {xPosition, yPosition} to position
                        set {xSize, ySize} to size
                    end tell
                    -- modify offsets if hot spot is not centered:
                    click at {xPosition + (xSize div 2) - 2 * xSize, yPosition + (ySize div 2) + gain * (ySize div 2)}
                end try
                
                delay 1
                keystroke "c" using command down
                
                tell application "Keynote" to activate
                
                delay 1
                
                keystroke "v" using command down
                
                --tell application "Numbers" to activate
                
                --delay 1
                --click button 6 of window 1
                --delay 1
                
            end if
            
            
            
            
            
        end tell
    end tell
end CreateChat
on CreateChat0(typeName)
    tell application "System Events"
        tell process "Numbers" -- 告诉 app
            click checkbox 1 of group 6 of toolbar 1 of window 1
            set gain to 8
            if typeName is "line" then
                set gain to (6.5)*5
            end if
            
            try
                tell checkbox 1 of group 6 of toolbar 1 of window 1
                    set {xPosition, yPosition} to position
                    set {xSize, ySize} to size
                end tell
                -- modify offsets if hot spot is not centered:
                click at {xPosition + (xSize div 2) - 2 * xSize, yPosition + (ySize div 2) + 4 * (ySize div 2)}
            end try
            try
                tell checkbox 1 of group 6 of toolbar 1 of window 1
                    set {xPosition, yPosition} to position
                    set {xSize, ySize} to size
                end tell
                -- modify offsets if hot spot is not centered:
                click at {xPosition + (xSize div 2) - 2 * xSize, yPosition + (ySize div 2) + gain * (ySize div 2)}
            end try
            
            delay 1
            keystroke "c" using command down
            
            tell application "Keynote" to activate
            
            delay 1
            
            keystroke "v" using command down
            
            --tell application "Numbers" to activate
            
            --delay 1
            --click button 6 of window 1
            --delay 1

            
            
        end tell
    end tell
end CreateChat0


on CloseKeynotes()
    tell application "Keynote"
    activate
    repeat with i from (count of documents) to 1 by -1
        set thisDocument to document i
        if file of thisDocument is missing value then
            close thisDocument without saving
        end if
    end repeat
end tell
end CloseKeynotes

on CloseNumbers()
    (*tell application "System Events"
        tell process "Numbers" -- 告诉 app
            activate
            set UiList to UI elements
            repeat with windowItem in UiList
                set isExit to 0
                set ItemUIs to UI elements in windowItem as list
                if the (count of ItemUIs) is 3 then
                    
                    repeat with itemName in ItemUIs
                        if name of itemName is "Delete" then
                            click button "Delete" of windowItem
                            --set isExit to 1
                            exit repeat
                        end if
                    end repeat
                end if
            end repeat
        end tell
    end tell*)
    tell application "Numbers"
    activate
    repeat with i from (count of documents) to 1 by -1
        set thisDocument to document i
        if file of thisDocument is missing value then
            close thisDocument without saving
        end if
    end repeat
end tell
end CloseNumbers


on addTableDataForFilter(docId, slideIndex, filepath, rowCount, columnCount, tab_height, txt_size,isOldVersion)
    tell application "Keynote"
        tell slide slideIndex of document id docId
            set tabledata to my readTabSeparatedValuesFile(filepath)
            if rowCount < 2 then
                set rowCount to 2
            end if

            if isOldVersion is 0 then
                set rowCount to toevennumber(rowCount) of me
            end if

            set thisTable to make new table with properties {row count:rowCount, column count:columnCount, name:"BM Filter Info", header row count:1, header column count:0,position:{1120,90},width:300}
            tell thisTable
                set rowIndex to 1
                set columnIndex to 1
                set font size of every cell to txt_size
                set the height of every row to tab_height
                set the rowCellCount to count of cells of row 2
                repeat with i from 1 to count of the tabledata -- get a data set from the data set list
                    set thisRowData to item i of the tabledata
                    tell row (i)
                        -- iterate the data set, populating row cells from left to right
                        repeat with q from 1 to the count of thisRowData
                            tell cell (q)
                                set value to item q of thisRowData
                                set alignment to center
                                set vertical alignment to center
                            end tell
                        end repeat
                    end tell
                end repeat
            end tell
            
        end tell
    end tell
    
end addTableData



on Moveposition(nSlide, nDocment)
    tell application "Keynote"
        activate
        tell slide nSlide of document id nDocment
            tell charts
                set position to {200, 200}
                set width to 1400
                set height to 600
            end tell
        end tell
    end tell
end Moveposition
on getRange(row, col)
    set start to "A1:"
    set listKey to {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"}
    set endfix to item col of listKey & row as string
    return start & endfix
end getRange
'''

if __name__ == '__main__':
    print("-----test----")
    test = source.format("{\"hear\",\"adad\"}","{\"data\"}","{{10,23}}")
    print(test)





