# %%
import os
import skimage.io
import matplotlib.pyplot as plt
import cv2
import numpy

path = '/home/bbales2/crts/graphics/sprites/hobglob'

ims = []

mw = 0
mh = 0

for f in os.listdir(path):
    im = cv2.imread(os.path.join(path, f), cv2.IMREAD_UNCHANGED)
    
    if im.shape[0] > mh:
        mh = im.shape[0]
        
    if im.shape[1] > mw:
        mw = im.shape[1]

    border = numpy.linalg.norm(im[:, :, :3] - [129.0, 78.0, 40.0], axis = 2) < 20.0        

    im[numpy.nonzero(border)] = 0     
     
    #plt.imshow(border)
    #plt.plot()
#    print numpy.nonzeros(
    ims.append((f, im))
    #print f
    #1/0
#%%
n = 8

ims = sorted(ims, key = lambda x : x[0])

tileset = numpy.zeros((6 * mh, n * mw, 4)).astype('uint8')

for i, (f, im) in enumerate(ims[:6 * 8 - 4]):
    oy = (i / 8) * mh + (mh - im.shape[0]) / 2
    ox = (i % 8) * mw + (mw - im.shape[1]) / 2
    print im.shape, ox, oy
    tileset[oy : oy + im.shape[0], ox : ox + im.shape[1], :3] = im[:, :, 2::-1]
    tileset[oy : oy + im.shape[0], ox : ox + im.shape[1], 3] = im[:, :, 3]
tileset = numpy.vstack((tileset, tileset[1 * mh : 4 * mh, ::-1]))

plt.imshow(tileset)

skimage.io.imsave('/home/bbales2/crts/processed_graphics/hobglob.png', tileset)
#%%
os