#!/usr/bin/env python

import re
import sys
import csv
from statistics import mean,stdev
import matplotlib.pyplot as plt
import numpy as np
import glob

timers = {}
traces = {}

timers_fnames = glob.glob('timers.*.csv')
sizes = [ x.split('.')[1] for x in timers_fnames ]
print(sizes)
sizes.sort(key=int)
print(sizes)
for size in sizes:
    with open('timers.{0}.csv'.format(size)) as f:
        timers[size] = {'adhoc_adios': {'left':{},'right':{}}, 'adhoc_dspaces':{'left':{},'right':{}},'benesh':{'left':{},'right':{}}}
        data = csv.reader(f, delimiter=',')
        for row in data:
            comp=row[0]
            side=row[1]
            name=row[2]
            timers[size][comp][side][name] = {}
            timers[size][comp][side][name]['raw'] = [float(x) / 1e6 for x in row[4:] ]
            timers[size][comp][side][name]['avg'] = mean(timers[size][comp][side][name]['raw'])
            if len(timers[size][comp][side][name]['raw']) > 1:
                timers[size][comp][side][name]['stdev'] = stdev(timers[size][comp][side][name]['raw'])
            else:
                timers[size][comp][side][name]['stdev'] = 0
    with open('traces.{0}.csv'.format(size)) as f:
        traces[size] = {'adhoc_adios':{'left':{},'right':{}},'adhoc_dspaces':{'left':{},'right':{}},'benesh':{'left':{},'right':{}}}
        data = csv.reader(f, delimiter=',')
        for row in data:
            comp=row[0]
            side=row[1]
            name=row[2]
            print(name)
            event,trial,*_ = re.split(r'(\d+)', name)
            t = int(trial)
            if t == 0:
                traces[size][comp][side][event] = []
            traces[size][comp][side][event].append({})
            traces[size][comp][side][event][t]['start_avg'] = mean([ float(x) / 1e6 for x in row[5::2] ])
            traces[size][comp][side][event][t]['end_avg'] = mean(float(x) / 1e6 for x in row[6::2])

resindices = []
for size in sizes:
    resindices.append((size, 'left'))
#    resindices.append((size, 'right'))

mments = [ f'{x[0]},{x[1]}' for x in resindices ]

aares = [ max(timers[x]['adhoc_adios']['left']['compute_slow']['avg'], timers[x]['adhoc_adios']['right']['compute_slow']['avg']) for x in sizes]
adres = [ max(timers[x]['adhoc_dspaces']['left']['compute_slow']['avg'], timers[x]['adhoc_dspaces']['right']['compute_slow']['avg']) for x in sizes]
bres = [ max(timers[x]['benesh']['left']['compute_slow']['avg'], timers[x]['benesh']['right']['compute_slow']['avg']) for x in sizes]
aaerr = [ (timers[x]['adhoc_adios']['left']['compute_slow']['stdev'] + timers[x]['adhoc_adios']['right']['compute_slow']['stdev']) /2 for x in sizes]
aderr = [ (timers[x]['adhoc_dspaces']['left']['compute_slow']['stdev'] + timers[x]['adhoc_dspaces']['right']['compute_slow']['stdev']) /2 for x in sizes]
berr = [ (timers[x]['benesh']['left']['compute_slow']['stdev'] + timers[x]['benesh']['right']['compute_slow']['stdev']) /2 for x in sizes]

print("size, adhoc_dspaces_time, adhoc_adios_time, adhoc_adios_time, adhoc_adios_err, benesh_time, benesh_err")
for step in range(len(adres)):
    print(f'{mments[step]},{aares[step]},{aaerr[step]}{adres[step]},{aderr[step]},{bres[step]},{berr[step]}')

width=0.25
X = np.zeros(len(sizes))
for pos in range(len(sizes)):
    X[pos] = 2 * pos

plt.bar(X, adres, width, label='adhoc_dspaces', yerr=aderr, hatch='//')
plt.bar(X + width, aares, width, label='adhoc_adios', yerr=aaerr, hatch='\\')
plt.bar(X + 2*width, bres, width, yerr=berr, label='benesh')
plt.ylabel('time(s)')
plt.xticks(X + width / 2, sizes)
plt.legend(loc='best')
plt.subplots_adjust(bottom=0.15)

plt.savefig('wallclock.png')
plt.cla()

trace_names = [('fill_ghosts','xkcd:hot pink'), ('euler_solve','xkcd:mustard'), ('advance','xkcd:sky blue'), ('read_peer','xkcd:forest green'), ('b_dspaces_check_sub','xkcd:forest green'), ('write_stage', 'xkcd:light salmon'), ('publish_var', 'xkcd:light salmon')]
yranges = { 'adhoc_adios': {'left': (0.,0.2), 'right': (0.3,.2)}, 'adhoc_dspaces': {'left': (1.0,.2), 'right': (1.3,.2)}, 'benesh': {'left': (2.0,.2), 'right': (2.3,.2)}}
measure = [ 'adhoc_adios,left', 'adhoc_adios,right', 'adhoc_dspaces,left', 'adhoc_dspaces,right', 'benesh,left', 'benesh,right' ]

for size in sizes:
    for (name,color) in trace_names:
        if name == "publish_var" or name == "b_dspaces_check_sub":
            nolabel = True
        else:
            nolabel = False
        for mode in traces[size]:
            for side in traces[size][mode]:
                if name in traces[size][mode][side]:
                    xranges = []
                    for t in traces[size][mode][side][name]:
                        xranges.append((t['start_avg'], t['end_avg'] - t['start_avg']))
                    if nolabel:
                        mylabel = None
                    else:
                        if name == "read_peer":
                            mylabel = "wait_read"
                        else:
                            mylabel = name
                    plt.broken_barh(xranges, yranges[mode][side], facecolors=color, label=mylabel)
                    nolabel = True
    plt.yticks( [ .15, .45, 1.15, 1.45, 2.15, 2.45 ], measure)
    plt.tight_layout()
    plt.legend(loc='lower right')
    plt.savefig(f'traces.{size}.png')
    plt.cla()


width = .07
timer_names = {'solve' : {'name': {'adhoc_adios': 'euler_solve', 'adhoc_dspaces': 'euler_solve', 'benesh': 'euler_solve'}, 'color':'xkcd:mustard'}, 'advance': {'name': {}, 'color': 'xkcd:sky blue'}, 'read_wait': {'name': {'adhoc_adios': 'read_peer', 'adhoc_dspaces': 'read_peer', 'benesh': 'b_dspaces_check_sub'}, 'color': 'xkcd:forest green'}, 'write': {'name': {'adhoc_adios': 'write_stage', 'adhoc_dspaces': 'read_peer', 'benesh' : 'publish_var'}, 'color': 'xkcd:light salmon'} }

name_pos = 0;
X = np.arange(len(sizes)) 
for name in timer_names:
    print(name)
    if not name == "read_wait":
        aname = ""
        bname = ""
        if len(timer_names[name]['name']) > 0:
            aname = timer_names[name]['name']['adhoc_dspaces']
            #aaname = timer_names[name]['name']['adhoc_adios']
            bname = timer_names[name]['name']['benesh']
        else:
            aname = name
            bname = name
        aatimes = []
        adtimes = []
        btimes = []
        for size in sizes:
            laadurs = [ x['end_avg'] - x['start_avg'] for x in traces[size]['adhoc_adios']['left'][aname] ]
            raadurs = [ x['end_avg'] - x['start_avg'] for x in traces[size]['adhoc_adios']['right'][aname] ]
            print(traces[size]['adhoc_dspaces']['left'])
            laddurs = [ x['end_avg'] - x['start_avg'] for x in traces[size]['adhoc_dspaces']['left'][aname] ]
            raddurs = [ x['end_avg'] - x['start_avg'] for x in traces[size]['adhoc_dspaces']['right'][aname] ]
            lbdurs = [ x['end_avg'] - x['start_avg'] for x in traces[size]['benesh']['left'][bname] ]
            rbdurs =  [ x['end_avg'] - x['start_avg'] for x in traces[size]['benesh']['right'][bname] ]
            aatimes.append((sum(laadurs) + sum(raadurs)) / 2)
            adtimes.append((sum(laddurs) + sum(raddurs)) / 2)
            btimes.append((sum(lbdurs) + sum(rbdurs)) / 2)
    
        offset = ((3 * name_pos) - 6) * width
        plt.bar(X + offset, aatimes, width, color=timer_names[name]['color'], hatch="*", edgecolor='black', label=f'adhoc_adios {name}')
        offset = ((3 * name_pos) - 5) * width
        plt.bar(X + offset, adtimes, width, color=timer_names[name]['color'], hatch="//", edgecolor='black', label=f'adhoc_dspaces {name}')
        offset = ((3 * name_pos) - 4) * width
        plt.bar(X + offset, btimes, width, color=timer_names[name]['color'], edgecolor='black', label=f'benesh {name}')
        name_pos = name_pos + 1;
aatimes = []
adtimes = []
btimes = []
for size in sizes:
    laardurs = [ x['end_avg'] - x['start_avg'] for x in traces[size]['adhoc_adios']['left']['read_peer'] ]
    raardurs = [ x['end_avg'] - x['start_avg'] for x in traces[size]['adhoc_adios']['right']['read_peer'] ]
    aatimes.append((sum(laardurs) + sum(raardurs)) / 2)
    ladrdurs = [ x['end_avg'] - x['start_avg'] for x in traces[size]['adhoc_dspaces']['left']['read_peer'] ]
    radrdurs = [ x['end_avg'] - x['start_avg'] for x in traces[size]['adhoc_dspaces']['right']['read_peer'] ]
    adtimes.append((sum(ladrdurs) + sum(radrdurs)) / 2)
    lbrdurs = [ x['end_avg'] - x['start_avg'] for x in traces[size]['benesh']['left']['b_dspaces_check_sub'] ]
    rbrdurs = [ x['end_avg'] - x['start_avg'] for x in traces[size]['benesh']['right']['b_dspaces_check_sub'] ]
    lbwdurs = timers[size]['benesh']['left']['wait_work']['avg']
    rbwdurs = timers[size]['benesh']['right']['wait_work']['avg']
    btimes.append((sum(lbrdurs) + sum(rbrdurs) + lbwdurs + rbwdurs) / 2)
offset = ((3 * name_pos) - 6) * width
plt.bar(X + offset, aatimes, width, color=timer_names['read_wait']['color'], hatch="*", edgecolor='white', label='adhoc_adios read')
offset = ((3 * name_pos) - 5) * width
plt.bar(X + offset, adtimes, width, color=timer_names['read_wait']['color'], hatch="//", edgecolor='white', label='adhoc_dspaces read')
offset = ((3 * name_pos) - 4) * width
plt.bar(X + offset, btimes, width, color=timer_names['read_wait']['color'], edgecolor='black', label='benesh read')
plt.ylabel('time(s)')
plt.xticks(X, sizes)
plt.legend(loc='best',prop={'size': 6})
plt.savefig('div_wallclock.png')
plt.cla()
