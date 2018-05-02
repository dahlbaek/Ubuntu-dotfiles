#!/home/dahlbaek/virtualenvs/mail/bin/python
"""Convert text/plain to multipart/alternative."""

from email import message, message_from_file, policy
from subprocess import run
from sys import argv, stdin
from pypandoc import convert_text

def main():
    """Run code."""

    # read mail from stdin
    msg = message_from_file(stdin, policy=policy.SMTP)

    # only convert if there is an inline text/plain part
    if msg.get_body(preferencelist=("plain",)):
        new_msg = message.MIMEPart(policy=policy.SMTP)
        # copy headers
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
        # make multipart/alternative
        inline = msg.get_body(preferencelist=("plain",))
        new_msg.add_alternative(
            inline.get_content(),
            charset="utf-8",
            cte="base64"
        )
        new_msg.add_alternative(
            convert_text(inline.get_content(), "html", format="md"),
            subtype="html",
            charset="utf-8",
            cte="base64"
        )
        # set multipart/alternative as inline
        new_msg["Content-Disposition"] = "inline"
        # append attachments
        for attachment in msg.iter_attachments():
            kwargs = {
                "maintype": attachment.get_content_maintype(),
                "subtype": attachment.get_content_subtype(),
                "disposition": attachment.get_content_disposition(),
                "filename": attachment.get_filename()
            }
            # assume attachment is text, otherwise assume attachment is base64 encoded
            try:
                new_msg.add_attachment(
                    attachment.get_content().encode("ascii"), # text encoded to byte string
                    **kwargs
                )
            except AttributeError:
                new_msg.add_attachment(
                    attachment.get_content(), # byte string
                    **kwargs
                )
    else:
        new_msg = msg

    # send
    msmtp_args = ["/usr/bin/msmtp", "-a", "AAU"]
    msmtp_args.extend(argv[1:])
    run(msmtp_args, input=new_msg.as_bytes())
    #print(out_msg.as_string())

if __name__ == "__main__":
    main()
