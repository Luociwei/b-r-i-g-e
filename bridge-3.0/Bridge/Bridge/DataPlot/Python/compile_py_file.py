#! /usr/bin/env python3
# --*-- coding: utf-8 ---*---

import sys,os,time

def compile_files():
    BASE_DIR=os.path.dirname(os.path.abspath(__file__))
    print('path',BASE_DIR)
    os.system('cd '+BASE_DIR+';python3 -O  -m compileall -b')
    bk_dir = os.path.expanduser('~')+'/Desktop/Xcode_Trash/sc'
    if not os.path.exists(bk_dir):
        os.mkdir(bk_dir)
    for root,dirs,files in os.walk(BASE_DIR):
        if root == BASE_DIR:
            for file in files:
                temp_path = BASE_DIR+'/'+file
                pathname,extension = os.path.splitext(temp_path)
                if extension == '.py' and file != 'compile_py_file.py':
                    os.system('cp '+temp_path+' '+bk_dir)
                    os.system('rm '+temp_path)
    os.system('cd '+BASE_DIR+'/python_keynote;python3 -O  -m compileall -b')
    os.system('rm '+BASE_DIR+'/python_keynote/generate_keynote.py')



if __name__ == '__main__':
    compile_files() 
