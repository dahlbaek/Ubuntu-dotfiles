#!/usr/bin/env python3

import subprocess
import threading
import time
import os

# Sync accounts asynchronously, but wait for all syncs to finish
def offlineimap():
    AAU = subprocess.Popen(['offlineimap', '-a AAU'], stderr = AAUlog)
    AU = subprocess.Popen(['offlineimap', '-a AU'], stderr = AUlog)
    AAU.communicate()
    AU.communicate()

# Sync every wait_time seconds, and when mutt closes
def autosync():
    while not mutt_has_closed:
        offlineimap()
        for i in range(wait_time):
            if not mutt_has_closed:
                time.sleep(1)
            else:
                offlineimap()
                break

wait_time = 300 # Seconds to wait between syncs
mutt_has_closed = False
imap_thread = threading.Thread(target=autosync)

# Open log files, start autosync, start mutt. When Mutt closes, wait for autosync to finish.
with open(os.path.expanduser('~/.config/offlineimap/AAU.log'),'w') as AAUlog, open(os.path.expanduser('~/.config/offlineimap/AU.log'),'w') as AUlog:
    imap_thread.start()
    subprocess.call('mutt')
    mutt_has_closed = True
    print('Synchronizing mailboxes. This may take a while.')
    imap_thread.join()
