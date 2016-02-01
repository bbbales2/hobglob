#%%

import struct
import numpy
import matplotlib.pyplot as plt

print a, w, h

#%%
f = open('/home/bbales2/Downloads/7kaa/resource/i_hill1.res')#sprite/japanese.spr')

b = f.read()

f.close()

s = 0
while s < len(b):
    a = struct.unpack('I', b[s : s + 4])[0]
    w = struct.unpack('h', b[s + 4 : s + 6])[0]
    h = struct.unpack('h', b[s + 6 : s + 8])[0]
    
    print a, w, h
    
    image = [struct.unpack('B', byte)[0] for byte in b[s + 8 : s + 4 + a]]
    
    b2 = []
    i = 0
    while i < len(image):
        byte = image[i]
        if byte == 0xf8:
            b2 += [0] * image[i + 1]
            
            i += 2
            continue
        elif byte > 0xf8 and byte <= 0xff:
            b2 += [0] * (256 - byte)
        else:
            b2 += [byte]
        
        i += 1

    if len(b2) < w * h:
        print 'error', (w * h - len(b2))
        b2 += [0] * (w * h - len(b2))
    
    #plt.imshow(numpy.array(b2).reshape(h, w, order = 'C'), interpolation = 'NONE')
    plt.imshow(numpy.array([cmap[v] for v in b2]).reshape(h, w, 3), interpolation = 'NONE')
    plt.show()
    
    s += 4 + a

#%%
f = open('/home/bbales2/Downloads/7kaa/resource/pal_std.res')#/home/bbales2/Downloads/7kaa/image/credits1.col')

b = f.read()

f.close()

#a = struct.unpack('I', b[:4])[0]
w = struct.unpack('h', b[0:2])[0]
h = struct.unpack('h', b[2:4])[0]
cmap = 255 - numpy.array([struct.unpack('B', byte)[0] for byte in b[8:]]).reshape(256, 3)

#%%
f = open('/home/bbales2/Downloads/7kaa/resource/std.set')#/home/bbales2/Downloads/7kaa/image/credits1.col')

b = f.read()

f.close()

records = struct.unpack('h', b[0:2])[0]

recordsList = []
for i in range(records):
    name = ''.join([struct.unpack('c', byte)[0] for byte in b[2 + i * 13 : 2 + i * 13 + 9]]).strip('\x00')
    offset = struct.unpack('I', b[2 + i * 13 + 9 : 2 + (i + 1) * 13])[0]
    print name, offset
    
    recordsList.append((name, offset))
#%%
data = b[129621 : 500943]

f = open('/home/bbales2/Downloads/7kaa/frames.dbf', 'w')
f.write(data)
f.close()
#h = struct.unpack('h', b[2:4])[0]
#cmap = 255 - numpy.array([struct.unpack('B', byte)[0] for byte in b[8:]]).reshape(256, 3)

#%%

f = open('/home/bbales2/Downloads/7kaa/image/credits1.icn')

b = f.read()

f.close()

#a = struct.unpack('I', b[:4])[0]
w = struct.unpack('h', b[0:2])[0]
h = struct.unpack('h', b[2:4])[0]

a = numpy.array([cmap[struct.unpack('B', byte)[0], :] for byte in b[4:]]).reshape(h, w, 3)
b = numpy.array([struct.unpack('B', byte)[0] for byte in b[4:]]).reshape(h, w)
plt.imshow(a, interpolation = 'NONE')

#%%
import skimage.io
skimage.io.imsave('/home/bbales2/crts/test.png', a.astype('uint8'))