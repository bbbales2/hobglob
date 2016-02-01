#%%
import dbfread

table = dbfread.DBF('/home/bbales2/Downloads/7kaa/frames.dbf', raw = True, lowernames = True)

entries = [entry for entry in table]

to_local_directions = {
    'E' : 'east',
    'SE' : 'southeast',
    'S' : 'south',
    'SW' : 'southwest',
    'W' : 'west',
    'NW' : 'northwest',
    'N' : 'north',
    'NE' : 'northeast',
    '' : None
}
#%%
processed = {}
for entry in entries:
    name = entry['sprite'].strip().lower()
        
    if name not in processed:
        processed[name] = []
        
    direction = entry['dir'].strip().lower()
    if direction not in to_local_directions:
        print name
    action = entry['action'].strip().lower()
    ox = int(entry['offset_x'].strip())
    frame = int(entry['frame'].strip())
    oy = int(entry['offset_y'].strip())
    
    processed[name].append({
        'frame' : frame,
        'action' : action,
        'direction' : direction,
        'ox' : ox,
        'oy' : oy
    })
    
for name in processed:
    processed[name] = sorted(processed[name], key = lambda x : (x['direction'], x['frame']))