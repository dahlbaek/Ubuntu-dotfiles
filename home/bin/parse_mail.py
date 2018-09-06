#!/home/dahlbaek/virtualenvs/mail/bin/python
"""Convert text/plain to multipart/alternative."""

from email import message, message_from_file, policy
from subprocess import run
from sys import argv, stdin

from pypandoc import convert_text


def convert(msg):
    """Convert markdown into html."""
    new_msg = make_new(msg)
    new_msg = add_alternative(msg, new_msg)
    new_msg = add_attachments(msg, new_msg)
    return new_msg

def make_new(msg):
    """Construct new message with headers."""
    new_msg = message.MIMEPart(policy=policy.SMTP)
    headers = [
        "Date",
        "From",
        "To",
        "CC",
        "Subject",
        "Message-ID",
        "MIME-Version",
    ]
    for header in headers:
        if msg[header]:
            new_msg[header] = msg[header]
    return new_msg

def add_alternative(msg, new_msg):
    """Convert markdown to html and add as multipart/alternative."""
    inline = msg.get_body(preferencelist=("plain",))
    new_msg.add_alternative(
        inline.get_content(),
        charset="utf-8",
        cte="base64"
    )
    new_msg.add_alternative(
        convert_text(inline.get_content(), "html", format="commonmark"),
        subtype="html",
        charset="utf-8",
        cte="base64"
    )
    new_msg["Content-Disposition"] = "inline"
    return new_msg

def add_attachments(msg, new_msg):
    """Add remaining attachments."""
    for attachment in msg.iter_attachments():
        kwargs = {
            "subtype": attachment.get_content_subtype(),
            "disposition": attachment.get_content_disposition(),
            "filename": attachment.get_filename(),
            "cte": "base64",
        }
        # assume attachment is text, otherwise assume attachment is base64 encoded
        try:
            charset = attachment.get_content_charset("ascii")
            new_msg.add_attachment(
                attachment.get_content(), # text string
                charset=charset,
                **kwargs,
            )
        except TypeError:
            maintype = attachment.get_content_maintype()
            new_msg.add_attachment(
                attachment.get_content(), # byte string
                maintype=maintype,
                **kwargs,
            )

def main():
    """Run code."""
    msg = message_from_file(stdin, policy=policy.SMTP)

    if msg.get_body(preferencelist=("plain",)):
        new_msg = convert(msg)
    else:
        new_msg = msg

    msmtp_args = ["/usr/bin/msmtp", "-a", "AAU"]
    msmtp_args.extend(argv[1:])
    run(msmtp_args, input=new_msg.as_bytes())

if __name__ == "__main__":
    main()
