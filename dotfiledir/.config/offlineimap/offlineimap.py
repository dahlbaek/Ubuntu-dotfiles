import subprocess

def remote(accountinfo):
    path = "/home/dahlbaek/.config/sensitive/imap/%s.gpg" % accountinfo
    return subprocess.check_output(["gpg2", "--quiet", "-d", path]).strip()

