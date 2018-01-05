#!/usr/bin/env python3
"""Open Mutt and synchronize mailboxes."""
from os.path import expanduser
from subprocess import run
from multiprocessing import Event, Process

# seconds to wait between syncs
WAIT_TIME = 60

def offlineimap(account):
    """Synchronize account once."""
    with open(expanduser("~/.config/offlineimap/{}.log".format(account)), "a") as account_log:
        run(["offlineimap", "-a", account], stderr=account_log)

def mutt(mutt_has_closed):
    """Open mutt."""
    run("mutt")
    mutt_has_closed.set()

def autosync(mutt_has_closed, account):
    """Clear log, then synchronize every WAIT_TIME seconds until mutt closes."""
    with open(expanduser("~/.config/offlineimap/{}.log".format(account)), "w"):
        pass
    while not mutt_has_closed.is_set():
        offlineimap(account)
        mutt_has_closed.wait(timeout=WAIT_TIME)

def main():
    """Open Mutt and synchronize mail."""
    # initialize
    accounts = ["AAU"]
    mutt_has_closed = Event()
    processes = []

    # create and start processes
    mutt_process = Process(target=mutt, args=(mutt_has_closed,))
    mutt_process.start()
    processes.append(mutt_process)
    for account in accounts:
        account_process = Process(target=autosync, args=(mutt_has_closed, account))
        account_process.start()
        processes.append(account_process)
    # join threads
    for process in processes:
        process.join()
    # sync mail once
    print("Synchronizing mailboxes. This may take a while.")
    for account in accounts:
        offlineimap(account)
    # clear password cache
    run(["killall", "-1", "gpg-agent"])

if __name__ == "__main__":
    main()
