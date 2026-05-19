#!/usr/bin/env python3
"""
Daemon that maps ROYUAN volume knob (ABS_VOLUME events) to wpctl volume changes.
Monitors all ROYUAN Consumer Control devices concurrently.
"""

import struct
import subprocess
import glob
import os
import sys
import threading

EVENT_FMT = 'llHHi'
EVENT_SIZE = struct.calcsize(EVENT_FMT)

EV_ABS = 3
ABS_VOLUME = 32

STEP_PERCENT = 2  # % per knob tick


def find_devices():
    devices = []
    for path in glob.glob('/dev/input/event*'):
        name_path = f'/sys/class/input/{os.path.basename(path)}/device/name'
        try:
            with open(name_path) as f:
                name = f.read().strip()
            if 'Consumer Control' in name and ('ROYUAN' in name or 'R83' in name):
                devices.append(path)
        except OSError:
            pass
    return sorted(devices)


def monitor(device):
    print(f'Monitoring {device}', file=sys.stderr, flush=True)
    prev_value = None
    try:
        with open(device, 'rb') as f:
            while True:
                data = f.read(EVENT_SIZE)
                if len(data) < EVENT_SIZE:
                    break
                _sec, _usec, etype, ecode, evalue = struct.unpack(EVENT_FMT, data)

                if etype != EV_ABS or ecode != ABS_VOLUME:
                    continue

                if prev_value is None:
                    prev_value = evalue
                    continue

                delta = evalue - prev_value
                prev_value = evalue

                if delta == 0:
                    continue

                pct = f'{abs(delta) * STEP_PERCENT}%'
                if delta > 0:
                    subprocess.run(
                        ['wpctl', 'set-volume', '@DEFAULT_AUDIO_SINK@', pct + '+', '-l', '1.5'],
                        check=False,
                    )
                else:
                    subprocess.run(
                        ['wpctl', 'set-volume', '@DEFAULT_AUDIO_SINK@', pct + '-'],
                        check=False,
                    )
    except OSError as e:
        print(f'ERROR on {device}: {e}', file=sys.stderr, flush=True)


def main():
    devices = find_devices()
    if not devices:
        print('ERROR: no ROYUAN Consumer Control device found', file=sys.stderr)
        sys.exit(1)

    threads = []
    for dev in devices:
        t = threading.Thread(target=monitor, args=(dev,), daemon=True)
        t.start()
        threads.append(t)

    for t in threads:
        t.join()


if __name__ == '__main__':
    main()
