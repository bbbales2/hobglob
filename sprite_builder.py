# %%
import os
import skimage.io
import matplotlib.pyplot as plt
import numpy
import re
import scipy.ndimage

path = '/home/bbales2/crts/SevenKingdoms_graphics/sprites/japanese'#hobglob

ims = []

mw = 0
mh = 0

animations = []

f = open(os.path.join(path, 'index.txt'))
for line in f:
    line = line.strip().split()
    
    frames = int(line[0])
    name = line[1].strip()
    direction = line[2].strip() if len(line) > 2 else None
    
    animations.append({
        'frames' : frames,
        'name' : name,
        'direction' : direction
    })
    
f.close()

images = []
for f in sorted(os.listdir(path)):
    if not re.search('.png', f):
        continue
    
    im = skimage.io.imread(os.path.join(path, f))
    
    images.append(im)
    
#%%
import skimage.filters
imt = skimage.color.rgb2gray(image) > 0
mass = skimage.filters.gaussian_filter(imt, 2.0)

plt.imshow(mass)

ys = numpy.arange(im.shape[0])
xs = numpy.arange(im.shape[1])

XS, YS = numpy.meshgrid(xs, ys, indexing = 'xy')

j = sum((XS * mass).flatten()) / sum(mass.flatten())
i = sum((YS * mass).flatten()) / sum(mass.flatten())
#%%

background = 0.0
borderVal = 214.0 / 360.0

s = 0

mirrors = {
    'northeast' : 'northwest',
    'east' : 'west',
    'southeast' : 'southwest'
}

mirror_animations = []

for animation in animations:
    print animation['name']
    animation_images = images[s : s + animation['frames']]

    maxh = max([image.shape[0] for image in animation_images])
    maxw = max([image.shape[1] for image in animation_images])

    processed_images = []
    for image in animation_images:
        processed = numpy.zeros((maxh, maxw, 4))  
        
        #imt = skimage.color.rgb2gray(image) > 0
        #mass = skimage.filters.gaussian_filter(imt, 2.0)
        
        #mass = mass * (mass > numpy.mean(mass) * 0.5)
        
        #ys = numpy.arange(imt.shape[0])
        #xs = numpy.arange(imt.shape[1])
        
        #XS, YS = numpy.meshgrid(xs, ys, indexing = 'xy')
        
        #j = sum((XS * mass).flatten()) / sum(mass.flatten())
        #i = sum((YS * mass).flatten()) / sum(mass.flatten())

        i, j = numpy.mean(numpy.where(numpy.sum(image, axis = 2) > 0), axis = 1)

        #i, j = scipy.ndimage.measurements.center_of_mass(numpy.sum(image, axis = 2) > 0)

        oi = max(0, processed.shape[0] / 2 - int(numpy.floor(i)))
        oj = max(0, processed.shape[1] / 2 - int(numpy.floor(j)))
        oim = min(oi + image.shape[0], processed.shape[0])
        ojm = min(oj + image.shape[1], processed.shape[1])

        processed[oi : oim, oj : ojm, :3] = image[:oim - oi, :ojm - oj]
        
        hsv = skimage.color.rgb2hsv(processed[:, :, :3])

        background = numpy.linalg.norm(processed, axis = 2) == 0
        border = numpy.abs(hsv[:, :, 0] - borderVal) < 0.05
        
        processed[border] = (0, 0, 0, 0)
        processed[1 - background] += (0, 0, 0, 255)
        
        processed_images.append(processed)

    animation['sprites'] = numpy.hstack(processed_images)
    animation['width'] = maxw
    animation['height'] = maxh
            
    if animation['direction'] in mirrors:
        mirrored_images = []
        
        for image in processed_images:
            mirrored_images.append(image[:, ::-1])
            
        mirror_animations.append({
            'frames' : animation['frames'],
            'name' : animation['name'],
            'direction' : mirrors[animation['direction']],
            'sprites' : numpy.hstack(mirrored_images),
            'width' : maxw,
            'height' : maxh
        })
        
    plt.imshow(animation['sprites'][:, :, :3])
    plt.show()
    #1/0

    s += animation['frames']
    
animations = animations + mirror_animations

#%%
direction_order = ['east', 'southeast', 'south', 'southwest', 'west', 'northwest', 'north', 'northeast']
direction_order = dict([(k, v) for v, k in enumerate(direction_order)])

def animation_order(x):
    return (x['name'], direction_order[x['direction']] if x['direction'] else len(direction_order))

animations = sorted(animations, key = animation_order)

#%%
maxWidth = max([animation['sprites'].shape[1] for animation in animations])
output = numpy.zeros((sum([animation['sprites'].shape[0] for animation in animations]), maxWidth, 4))

s = 0
for i, animation in enumerate(animations):
    output[s : s + animation['sprites'].shape[0], :animation['sprites'].shape[1]] = animation['sprites']
    s += animation['sprites'].shape[0]

skimage.io.imsave('/home/bbales2/crts/all.png', output.astype('uint8'))
#%%
plt.imshow(im)
#plt.imshow(numpy.ma.masked_where(border, border))
plt.show()

plt.imshow(im)
plt.show()

hsv = skimage.color.rgb2hsv(im)
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