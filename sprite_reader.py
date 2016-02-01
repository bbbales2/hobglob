#%%

import skimage.io
import matplotlib.pyplot as plt
import numpy

path = '/home/bbales2/crts/SevenKingdoms_graphics/sprites/norman/0000.png'

im = skimage.io.imread(path)

background = 0.0
borderVal = 214.0 / 360.0
colorVal = 45.0 / 360.0

hsv = skimage.color.rgb2hsv(im)

background = hsv[:, :, 0] == background
border = numpy.abs(hsv[:, :, 0] - borderVal) < 0.05
colors = numpy.abs(hsv[:, :, 0] - colorVal) < 0.03

plt.imshow(im)
#plt.imshow(numpy.ma.masked_where(border, border))
plt.show()

im[border] = (0, 0, 0)
plt.imshow(im)
plt.show()

hsv = skimage.color.rgb2hsv(im)

for a in numpy.linspace(0.0, 1.0, 5, endpoint = False):
    im2 = numpy.array(hsv)
    im2[colors] += [a, 0.0, 0.0]
    print a
    plt.imshow(skimage.color.hsv2rgb(im2))
    plt.show()