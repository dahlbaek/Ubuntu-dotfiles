#!/usr/bin/env python

import subprocess
import threading
import time
import os

AAUlog = open(os.path.expanduser('~/.config/offlineimap/AAU.log'),'w')
AUlog = open(os.path.expanduser('~/.config/offlineimap/AU.log'),'w')

def offlineimap():
    AAU = subprocess.Popen(['offlineimap', '-a AAU'], stderr = AAUlog)
    AU = subprocess.Popen(['offlineimap', '-a AU'], stderr = AUlog)
    AAU.communicate()
    AU.communicate()

def autosync():
    while muttisopen:
        offlineimap()
        for i in range(1,120):
            if muttisopen:
                time.sleep(1)
            else:
                offlineimap()
                break

goimap = threading.Thread(target=autosync)

muttisopen = True
goimap.start()
subprocess.call('mutt')
muttisopen = False

print('Finishing mailbox sync. This may take a while.')
