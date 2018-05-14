#!/usr/bin/python
#coding:utf-8

import sys,os
from PIL import Image

print '使用说明:传入两个参数,第一个是大图片的路径,第二个是保存文件的路径'
sourcePath = sys.argv[1]
saveDir = sys.argv[2]
# saveIMSETRoot = '%s/iOS/AppIcon.appiconset'%(saveDir)
# saveIconsRoot = '%s/iOS/icons'%(saveDir)
# saveAndroidRoot = '%s/Android'%(saveDir)
# if not os.path.exists(saveIMSETRoot):
#     os.makedirs(saveIMSETRoot)
# if not os.path.exists(saveIconsRoot):
#     os.makedirs(saveIconsRoot)
# if not os.path.exists(saveAndroidRoot):
#     os.makedirs(saveAndroidRoot)

#打开照片编辑
im = Image.open(sourcePath)

sizeArr = [40,58,60,80,87,120,121,180,1024]
#(x,y) = im.size
for wh in sizeArr:
    # 保持采样率Image.ANTIALIAS
    newImg = im.resize((wh,wh),Image.ANTIALIAS)
    savePath = '%s/Icon-%s.png'%(saveDir,wh)
    newImg.save(savePath, 'png', quality = 100)

##要裁剪的大小数组(安卓)
#sizeArr = [48,72,96,144]
##(x,y) = im.size
#for wh in sizeArr:
#    # 保持采样率Image.ANTIALIAS
#    newImg = im.resize((wh,wh),Image.ANTIALIAS)
#    savePath = '%s/icon-%s.png'%(saveAndroidRoot,wh)
#    newImg.save(savePath, 'png', quality = 100)

#要裁剪的大小数组(iOS)
#sizeArr = [20,29,40,41,42,58,59,60,76,80,81,87,120,121,152,167,180,1024]
##(x,y) = im.size
#for wh in sizeArr:
#    # 保持采样率Image.ANTIALIAS
#    newImg = im.resize((wh,wh),Image.ANTIALIAS)
#    savePath = '%s/Icon-%s.png'%(saveIMSETRoot,wh)
#    newImg.save(savePath, 'png', quality = 100)

## @2x图片(iOS)
#sizeArrTwo = [72,76]
#for wh in sizeArrTwo:
#    # 保持采样率Image.ANTIALIAS
#    newImg = im.resize((wh * 2,wh * 2),Image.ANTIALIAS)
#    savePath = '%s/Icon-%s@2x.png'%(saveIconsRoot,wh)
#    newImg.save(savePath, 'png', quality = 100)

## @3x图片(iOS)
#sizeArrThree = [72]
#for wh in sizeArrThree:
#    # 保持采样率Image.ANTIALIAS
#    newImg = im.resize((wh * 3,wh * 3),Image.ANTIALIAS)
#    savePath = '%s/Icon-%s@3x.png'%(saveIconsRoot,wh)
#    newImg.save(savePath, 'png', quality = 100)
#
## icons下的其他图片(iOS)
#sizeArrOther = [72,76,120,50,29,512]
#nameArrOther = ['Icon-72.png','Icon-76.png','Icon-120.png','Icon-Small-50.png','Icon-Small.png','iTunesArtwork']
#for index in range(0,len(sizeArrOther)):
#    # 保持采样率Image.ANTIALIAS
#    newImg = im.resize((sizeArrOther[index],sizeArrOther[index]),Image.ANTIALIAS)
#    savePath = '%s/%s'%(saveIconsRoot,nameArrOther[index])
#    newImg.save(savePath, 'png', quality = 100)

im.close()
#print '裁剪的尺寸为: %s'%sizeArr
print '保存到文件夹: %s'%saveDir
print '***********执行完毕***********'
