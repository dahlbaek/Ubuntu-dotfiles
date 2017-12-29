#!/usr/bin/env python3
"""Open Mutt and synchronize mailboxes."""

import subprocess
import threading
import os

# seconds to wait between syncs
WAIT_TIME = 60

# sync accounts once asynchronously, and wait for all syncs to finish
def offlineimap(aaulog, aulog):
    """Synchronize accounts."""
    aausync = subprocess.Popen(['offlineimap', '-a AAU'], stderr=aaulog)
    ausync = subprocess.Popen(['offlineimap', '-a AU'], stderr=aulog)
    aausync.communicate()
    ausync.communicate()

# sync every wait_time seconds and once after mutt closes
def autosync(mutt_has_closed, aaulog, aulog):
    """Resynchronize every WAIT_TIME seconds."""
    while not mutt_has_closed.is_set():
        offlineimap(aaulog, aulog)
        mutt_has_closed.wait(timeout=WAIT_TIME)
    offlineimap(aaulog, aulog)

def main():
    """Open Mutt and synchronize mail."""
    # prepare thread
    aaulog = os.path.expanduser('~/.config/offlineimap/AAU.log')
    aulog = os.path.expanduser('~/.config/offlineimap/AU.log')
    mutt_has_closed = threading.Event()
    with open(aaulog, 'w') as aaulog, open(aulog, 'w') as aulog:
        imap_thread = threading.Thread(target=autosync, args=(mutt_has_closed, aaulog, aulog,))
        # open log files, start thread, start mutt. When Mutt closes, kill thread gracefully.
        imap_thread.start()
        subprocess.call('mutt')
        mutt_has_closed.set()
        print('Synchronizing mailboxes. This may take a while.')
        imap_thread.join()

if __name__ == "__main__":
    main()
