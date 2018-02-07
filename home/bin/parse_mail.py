#!/usr/bin/python3
"""Convert text/plain to multipart/alternative."""

from email import charset, message, message_from_file, policy
from subprocess import run
from sys import argv, stdin
from pypandoc import convert_text

def main():
    """Run code."""

    # allow 8bit encoded utf-8
    charset.add_charset('utf-8', charset.SHORTEST, '8bit')

    # read mail from stdin
    msg = message_from_file(stdin, policy=policy.SMTP)

    # determine if conversion should take place
    convert_simple = all([
        not msg.is_multipart(),
        msg.get_content_type() == "text/plain",
        msg.get_content_disposition() == "inline",
    ])
    convert_multi = all([
        msg.get_content_type() == "multipart/mixed",
        not any([part.is_multipart() for part in list(msg.walk())[1:]]),
        len([part for part in msg.walk() if part.get_content_disposition() == "inline" and part.get_content_type() == "text/plain"]) == 1,
    ])
    convert = any([convert_simple, convert_multi])

    if convert:
        # extract attachments
        attachments = []
        for part in msg.walk():
            if part.is_multipart():
                continue
            elif part.get_content_disposition() == "inline" and part.get_content_type() == "text/plain":
                inline = part.get_payload()
            else:
                attachments.append(part)
        # copy headers
        headers = [
            "Date",
            "From",
            "To",
            "CC",
            "Subject",
            "Message-ID",
        ]
        new_msg = message.EmailMessage(policy=policy.SMTP)
        for header in headers:
            if msg[header]:
                new_msg[header] = msg[header].replace("\r\n\t", "")
        new_msg.add_header("MIME-Version", "1.0")
        # make plain and html parts
        text_plain = message.MIMEPart(policy=policy.SMTP)
        text_plain.set_content(
            inline,
            charset="utf-8",
            cte="8bit"
        )
        text_html = message.MIMEPart(policy=policy.SMTP)
        text_html.set_content(
            convert_text(inline, "html", format="md"),
            subtype="html",
            charset="utf-8",
            cte="8bit")
        # attach attachments
        if convert_simple:
            new_msg.make_alternative()
            new_msg.attach(text_plain)
            new_msg.attach(text_html)
        elif convert_multi:
            new_msg.make_mixed()
            alternative = message.EmailMessage(policy=policy.SMTP)
            alternative.add_header("MIME-Version", "1.0")
            alternative.make_alternative()
            alternative.add_header("Content-Disposition", "inline")
            alternative.attach(text_plain)
            alternative.attach(text_html)
            new_msg.attach(alternative)
            for part in attachments:
                new_msg.attach(part)
        out_msg = new_msg
    else:
        out_msg = msg

    # send
    msmtp_args = ["/usr/bin/msmtp", "-a", "AAU"]
    msmtp_args.extend(argv[1:])
    run(msmtp_args, input=out_msg.as_bytes())
    #print(out_msg.as_string())

if __name__ == "__main__":
    main()
