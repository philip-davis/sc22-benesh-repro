#!/usr/bin/python3

import sys
import json

events = {}

nranks = int(sys.argv[1])
timesteps = 4;

for rank in range(nranks):
    try:
        with open('trace_events.{0}.json'.format(rank)) as f:
            data = json.load(f)
            for event in data['traceEvents']:
                if 'dur' in event:
                    name = event['name']
                    if not name in events:
                        events[name] = []
                        for i in range(nranks):
                            events[name].append(list())
                    events[name][rank].append({'ts': event['ts'], 'dur': event['dur']})
    except FileNotFoundError:
        pass


datapoints = [
        'fill_ghosts',
        'euler_solve',
        'advance',
        'read_peer',
        'write_stage',
        'publish_var',
        'b_dspaces_check_sub'
        ]

#print('name, first_start, last_end')
for dp in datapoints:
    if dp not in events:
        continue
    for step in range(timesteps):
        start = []
        end = []
        for rank in range(len(events[dp])):
            if len(events[dp][rank]) > step:
                start.append(events[dp][rank][step]['ts'] - (events['compute phase'][rank][0]['ts']))
                end.append(start[len(start)-1] + events[dp][rank][step]['dur'])
        if len(start) > 0:
            first_start = min(start)
            last_end = max(end)
            print(f"{dp}{step}, {first_start}, {last_end}")
