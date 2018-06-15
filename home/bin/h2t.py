import argparse
import html2text
import pypandoc

def main():
    p = argparse.ArgumentParser()
    h = html2text.HTML2Text()

    p.add_argument("filename")
    filename = p.parse_args().filename

    h.ignore_emphasis = True
    h.body_width = 0
    h.use_automatic_links = False
    h.wrap_links = False
    h.single_line_break = True

    with open(filename, "r") as data:
        try:
            text = data.read()
        except UnicodeDecodeError:
            with open(filename, mode="r", encoding="iso-8859-1") as data:
                text = data.read()

    init = h.handle(text)
    print(init)

if __name__ == "__main__":
    main()

