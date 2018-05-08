#!/usr/bin/python
#coding:UTF-8

import sys,os,time
from selenium import webdriver
print '''
============使用说明============
传入两个参数:1.上传的网址;2.上传的文件夹
'''
global elements         # index.html的网页input元素
global maxInputCount    # 每次最大上传数量

# 提供一个函数刷新网页,更新元素
def refreshUploadhtml():
    global elements,maxInputCount
    options = webdriver.ChromeOptions()
    options.set_headless()
    options.add_argument('--disable-gpu')
    browser = webdriver.Chrome(options=options)
    browser.get(sys.argv[1])
    elements = browser.find_elements_by_tag_name('input')
    maxInputCount = len(elements) - 1


#1.将要上传的文件传入一个数组
fileList = []
for root,dir,files in os.walk(sys.argv[2]):
    for ele in files:
        fileList.append(os.path.join(root,ele))

#2.分批上传
#先获得上传网页信息
refreshUploadhtml()
#分批上传,先上传每个文件的路径,上传完立马判断是否已经达到最大的上传个数,达到了限制个数先上传,上传完之后休眠2秒在刷新网页上传下一批,上传忘了最后一个文件后要点击上传
hasInputCount = 0
for index in range(0,len(fileList)):
    # 排除DS_Store文件
    if 'DS_Store' in fileList[index]:
        continue
    # 一次添加文件
    inputEle = elements[hasInputCount]
    file = fileList[index]
    # 先清空内容,再传路径
    inputEle.clear()
    inputEle.send_keys(file.decode('utf-8'))
    print 'input %s'%fileList[index]
    # 统计添加个数
    hasInputCount += 1
    # 达到最大或者最后一个文件要提交,提交完了要刷新
    if hasInputCount == maxInputCount or index == (len(fileList) - 1):
        hasInputCount = 0
        sumitBtn = elements[-1]
        sumitBtn.click()
        print 'commit'
        time.sleep(3)
        refreshUploadhtml()



