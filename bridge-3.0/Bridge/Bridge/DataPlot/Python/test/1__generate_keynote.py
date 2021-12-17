# coding=utf-8
# -*- coding: utf-8 -*-

import sys
import os
import datetime
BASE_DIR=os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0,BASE_DIR+'/site-packages/')

from functools import partial
from pytz import timezone
import pytz




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
    print('python import ---->OSAScript')
 
    keynote = OSAScript(source)
    print('keynote---->',keynote)
    doc = keynote.newPresentation(u'White')
    print('doc---->',doc)

    # slide = keynote.createSlide(doc, u'Title - Center')
    slide = keynote.createSlide_ex(doc, u'Title - Center',title_msg,'/Users/RyanGao/Downloads/ParetoChart-master-2/test_001/apple_log.png')
    # m_slide = False
    # try:
    #     # slide = keynote.createSlide(doc, u'Title - Center')


    # except Exception as e:
    #     m_slide = True
    #     print('1.>slide Title - Center error',e)

    # if m_slide: 
    #     try:
    #         m_slide = False
    #         slide = keynote.createSlide(doc, u'Title - Centre')
    #     except Exception as e:
    #         m_slide = True
    #         print('2.>>slide Title - Centre error',e)
    # if m_slide:
    #     try:
    #         m_slide = False
    #         slide = keynote.createSlideWithFullBlank(doc)
    #     except Exception as e:
    #         m_slide = True
    #         print('3.>>>slide Title - Centre error',e)

    # slide = keynote.createSlideWithFullBlank(doc)
    # print('slide---->',slide)
    keynote.addText_ex(doc, slide, 1, title_msg)
    # keynote.addStyledTextTitle(doc,slide,title_msg)
    keynote.addStyledTextItem3(doc,slide,'Date: '+str(get_pst_time()))

    return doc,keynote

def add_overall_pic(doc,keynote,path):
    slide0 = keynote.createSlideWithFullBlank(doc)
    keynote.insertSlideWithFullImage(doc,slide0,path) #  insert overall pic


def add_one_pic(doc,keynote,pic_path,message):
    slide = keynote.createSlide(doc, u'Photo')
    keynote.addImage(doc,slide,0,pic_path)
    keynote.addPresenterNotes(doc,slide,message)

def add_fail_pic(doc,keynote,pic_path,item_name,description_info,root_cause_info,plan_info):
    slide = keynote.createSlideWithImage(doc, pic_path)
    # if len(item_name) > 70:
    #     item_name = item_name[0:70] + '\n' + item_name[70:]
    item_name = checkItemName(item_name,70)
    keynote.addStyledTextItemTitle(doc,slide,item_name)
    keynote.addStyledTextItem1(doc,slide,description_info)
    keynote.addStyledTextItem2(doc,slide,root_cause_info)
    keynote.addStyledTextItem3(doc,slide,plan_info)


def save_keynote(doc,keynote,save_keynote_path):
    keynote.finalize(doc)
    keynote.savePresentation(doc,save_keynote_path)
    # keynote.closePresentation(doc)
    # keynote.deleteAllSlides(doc)
    print("<<<save keynote file finished>>>")


source = '''on newPresentation(themeName)
    tell application "Keynote"
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
    end tell
end savePresentation    

on closePresentation(docId)
    tell application "Keynote"  
        set theDocument to document id docId
        close theDocument
    end tell
end savePresentation    


on createSlide(docId, masterSlideName)
    tell application "Keynote"
        tell document id docId
            set thisSlide to make new slide with properties {base slide:master slide masterSlideName}
            set thisShape to make new shape with properties {position:{0, 0}, width:1880, height:1080}
            
            tell shape2 of thisShape

                set it's size to 44
                set it's color to {0, 0, 65535} -- blue
           end tell


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

on addImage(docId, slideIndex, n, filepath)
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

on addStyledTextItem(docId, slideIndex, theText, theStyleList, thePosition, theSize, theFont)
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
                repeat with i from 1 to my min(the length of theStyleList, the length of theText)
                    set thisRGBColorValue to item i of theStyleList
                    set the color of character i of object text to thisRGBColorValue
                end repeat
            end tell
        end tell
    end tell
end addStyledTextItem

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
                make new image with properties {file:theImage, width:1024, height:700, position:{400, 80}}
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



on addStyledTextTitle(docId,slideIndex,txt)
   addStyledTextItem(docId, slideIndex,txt, [], {200, 350}, 85, "Helvetica")
end addStyledTextTitle

on addStyledTextItemTitle(docId,slideIndex,txt)
   addStyledTextItem(docId, slideIndex,txt, [], {130, 10}, 40, "Helvetica")
end addStyledTextItemTitle

on addStyledTextItem1(docId,slideIndex,txt)
   addStyledTextItem(docId, slideIndex,txt, [], {100, 810}, 40, "Helvetica")
end addStyledTextItem1

on addStyledTextItem2(docId,slideIndex,txt)
   addStyledTextItem(docId, slideIndex,txt, [], {100, 870}, 40, "Helvetica")
end addStyledTextItem2

on addStyledTextItem3(docId,slideIndex,txt)
   addStyledTextItem(docId, slideIndex,txt, [], {100, 930}, 40, "Helvetica")
end addStyledTextItem3

on min(a, b)
    if a < b then
        set x to a
    else
        set x to b
    end if
    return x
end min


'''

if __name__ == '__main__':
    print("-----test----")

    keynote_title_name = 'hhhh_dddd_dddd'
    doc,keynote = create_keynote(keynote_title_name)
    keynote_save_path = '/Users/RyanGao/Desktop/CPK_Log/cpk_report001.key'
    # keynote.createSlide_ex(doc, u'Title - Center',keynote_title_name,'/Users/RyanGao/Downloads/ParetoChart-master-2/test_001/apple_log.png')
    save_keynote(doc,keynote,keynote_save_path)

    # title_name = "J5XX_FCT_P1_DATA Review"
#    description_info =  'Issue description:\n'
#    root_cause_info = 'Root Cause:\n'
#    plan_info = 'Next steps:'
    # keynote_save_path = "/Users/rex/Desktop/CPK_Log/cpk_report001.key"
#    overall_pic_path = '/Users/rex/Desktop/CPK_Log/whole_cpk.png'
#    fail_pic_path = '/Users/rex/Desktop/CPK_Log/fail_plot/Accelerometer Selftest accel_selftest_x_symerr.png'


    # slide0 = keynote.createSlideWithFullBlank(doc)  # 第一张总图 占位置 ，为 slide0
  
    # slide = keynote.createSlideWithImage(doc, "/Users/RyanGao/Desktop/CPK_Log/fail/cpk1.png")
    # keynote.addStyledTextItem1(doc,slide,"Issue Description:")
    # keynote.addStyledTextItem2(doc,slide,"Root Cause:")
    # keynote.addStyledTextItem3(doc,slide,"Next steps:")
 
    # slide = keynote.createSlideWithImage(doc, "/Users/RyanGao/Desktop/CPK_Log/fail/cpk1.png")
    # keynote.addStyledTextItem1(doc,slide,"Issue Description:")
    # keynote.addStyledTextItem2(doc,slide,"Root Cause:")
    # keynote.addStyledTextItem3(doc,slide,"Next steps:")
 
    # slide = keynote.createSlideWithImage(doc, "/Users/RyanGao/Desktop/CPK_Log/fail/cpk1.png")
    # keynote.addStyledTextItem1(doc,slide,"Issue Description:")
    # keynote.addStyledTextItem2(doc,slide,"Root Cause:")
    # keynote.addStyledTextItem3(doc,slide,"Next steps:")
 
    # keynote.insertSlideWithFullImage(doc,slide0,"/Users/RyanGao/Desktop/CPK_Log/fail/cpk2.png") #  在slide0 插入图片

    # doc,keynote = create_keynote(title_name)
    # # add_overall_pic(doc,keynote,overall_pic_path)
    # # add_fail_pic(doc,keynote,fail_pic_path,description_info,root_cause_info,plan_info)
    # save_keynote(doc,keynote,keynote_save_path)




