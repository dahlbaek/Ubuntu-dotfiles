"""For offlineimap."""

from subprocess import check_output
from os.path import expanduser

def remote(accountinfo):
    """Pass."""
    if accountinfo in ["AUhost", "AUuser", "AUpass", "AAUhost", "AAUuser", "AAUpass"]:
        path = expanduser("~/.config/sensitive/mail/%s.gpg" % accountinfo)
        return check_output(["gpg2", "--quiet", "-d", path]).strip()

