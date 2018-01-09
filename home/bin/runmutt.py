#!/usr/bin/env python3
"""Open Mutt and synchronize mailboxes."""

from os.path import expanduser
from subprocess import run
from multiprocessing import Event, Process
from contextlib import ExitStack

def offlineimap(account):
    """Synchronize one account once and write to log."""

    with open(expanduser("~/.config/offlineimap/{}.log".format(account)), "a") as account_log:
        run(["offlineimap", "-a", account], stderr=account_log)

class Mutt:
    """Context manager for mutt."""

    def __init__(self, closing):
        self.closing = closing
        self.process = Process(target=self.start)

    def __enter__(self):
        self.process.start()
        return self

    def __exit__(self, exc_type, exc_value, traceback):
        self.process.join()

    def start(self):
        """Start mutt."""
        run("mutt")
        print("Synchronizing mailboxes. This may take a while.")
        self.closing.set()

class AutoSync:
    """Context manager for autosync."""

    def __init__(self, account, wait_time, closing):
        self.account = account
        self.wait_time = wait_time
        self.closing = closing
        self.process = Process(target=self.sync, args=(self.account,))

    def __enter__(self):
        self.process.start()
        return self

    def __exit__(self, exc_type, exc_value, traceback):
        self.process.join()

    def sync(self, account):
        """Synchronize all accounts every wait_time seconds until mutt closes."""
        while not self.closing.is_set():
            offlineimap(account)
            self.closing.wait(timeout=self.wait_time)
        # sync once more after mutt has closed
        offlineimap(account)

class Client:
    """Context manager for mutt client."""

    def __init__(self, accounts=None, wait_time=60):
        self.accounts = accounts
        self.wait_time = wait_time

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_value, traceback):
        # send SIGHUP to gpg-agent, which clears the password cache
        run(["killall", "-1", "gpg-agent"])

    def start(self):
        """Clears logs and starts everything."""

        # clear logs
        for account in self.accounts:
            with open(expanduser("~/.config/offlineimap/{}.log".format(account)), "w"):
                pass

        # create event to signal when mutt closes
        closing = Event()
        # start mutt and autosync mailboxes
        processes = []
        with ExitStack() as stack:
            processes.append(stack.enter_context(Mutt(closing)))
            processes.extend([stack.enter_context(AutoSync(account, self.wait_time, closing)) for account in self.accounts])

def main():
    """Open Client."""

    with Client(accounts=["AAU"], wait_time=60) as client:
        client.start()

if __name__ == "__main__":
    main()
