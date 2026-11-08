#!/usr/bin/env python3

"""Python 3 Simple HTTP Server With Upload feature.

This builds on the standard library ``http.server`` module. It serves files
from the current directory and its subdirectories (the normal GET/HEAD
behaviour) and additionally accepts file uploads via multipart/form-data
POST requests, so you get an "upload" form on every directory listing.

Python 2 original by Tony Pajamas; ported to Python 3 / http.server.
"""

import argparse
import html
import http.server
import io
import os
import re
import socketserver
import sys
from urllib.parse import quote, unquote

__version__ = "2.0"
__all__ = ["SimpleHTTPRequestHandler"]
__author__ = "Tony Pajamas"
__home_page__ = "https://youtube.com/"


class SimpleHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    """HTTP request handler with GET/HEAD/POST commands.

    GET/HEAD are inherited unchanged from the standard library handler.
    POST accepts a multipart/form-data upload and saves the file into the
    directory named by the request path.
    """

    server_version = "Tony v" + __version__ + " ~"

    def do_POST(self):
        """Serve a POST request (file upload)."""
        ok, info = self.deal_post_data()
        print(ok, info, "by: ", self.client_address)

        success = (
            "<strong>Success:</strong>\n"
            if ok
            else "<strong>Failed! Something went wrong and you suck.:</strong>\n"
        )
        referer = self.headers.get("referer", "/")
        page = (
            '\n<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">\n'
            "<html>\n"
            "<head>\n"
            "<title>Upload Result Page</title>\n"
            "<style>\n"
            ".power {\n"
            "    position:absolute;\n"
            "    bottom:6px;\n"
            "    right:8px;\n"
            "}\n"
            "</style>\n"
            "</head>\n"
            '<body style="background-color:#333333" text="#d9d9d9" a link="#00e6e6" vlink="#008080">\n'
            "<h2>Upload Result Page</h2>\n"
            "<hr>\n"
            + success
            + "        " + html.escape(info) + "\n"
            + '        <br><a href="' + html.escape(referer) + '">back</a>\n'
            + "        <hr>\n"
            '        <small class="power">Powered By: Tony Pajamas | '
            '<a href="http://youtube.com/" target="_blank" >Smash that like</a>.</small>\n'
            "</body>\n"
            "</html>\n"
        )

        encoded = page.encode("utf-8", "surrogateescape")
        self.send_response(200)
        self.send_header("Content-type", "text/html; charset=utf-8")
        self.send_header("Content-Length", str(len(encoded)))
        self.end_headers()
        self.wfile.write(encoded)

    def deal_post_data(self):
        """Parse a multipart/form-data body and write the uploaded file.

        Returns a (success, message) tuple.
        """
        content_type = self.headers.get("content-type")
        if not content_type:
            return (False, "Content-Type header is missing")
        match = re.search(r'boundary=(?:"([^"]+)"|([^;]+))', content_type)
        if not match:
            return (False, "Can't find the multipart boundary")
        boundary = (match.group(1) or match.group(2)).strip().encode("latin-1")

        remainbytes = int(self.headers.get("content-length", 0))

        line = self.rfile.readline()
        remainbytes -= len(line)
        if boundary not in line:
            return (False, "Content NOT begin with boundary")

        line = self.rfile.readline()
        remainbytes -= len(line)
        fn = re.findall(
            r'Content-Disposition.*name="file"; filename="(.*)"',
            line.decode("utf-8", "surrogateescape"),
        )
        if not fn:
            return (False, "Can't find out file name...")

        path = self.translate_path(self.path)
        filename = os.path.join(path, os.path.basename(fn[0]))

        # Skip the Content-Type line and the blank line after the headers.
        line = self.rfile.readline()
        remainbytes -= len(line)
        line = self.rfile.readline()
        remainbytes -= len(line)

        try:
            out = open(filename, "wb")
        except OSError:
            return (False, "Can't create file to write, do you have permission to write?")

        with out:
            preline = self.rfile.readline()
            remainbytes -= len(preline)
            while remainbytes > 0:
                line = self.rfile.readline()
                remainbytes -= len(line)
                if boundary in line:
                    preline = preline[:-1]
                    if preline.endswith(b"\r"):
                        preline = preline[:-1]
                    out.write(preline)
                    return (True, "File '%s' upload success!" % filename)
                out.write(preline)
                preline = line
        return (False, "Unexpected end of data.")

    def list_directory(self, path):
        """Produce a styled directory listing with an upload form."""
        try:
            entries = os.listdir(path)
        except OSError:
            self.send_error(404, "No permission to list directory")
            return None
        entries.sort(key=lambda a: a.lower())

        displaypath = html.escape(unquote(self.path))
        f = io.BytesIO()
        f.write(b'<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">\n')
        f.write(
            (
                "<html>\n<head>\n<title>Directory listing for %s</title>\n"
                "<style>\n.power {\n    position:absolute;\n    bottom:6px;\n"
                "    right:8px;\n}\n</style>\n</head>\n" % displaypath
            ).encode("utf-8")
        )
        f.write(
            (
                '<body style="background-color:#333333" text="#d9d9d9" a link="#00e6e6" '
                'vlink="#009999">\n<h2>Directory listing for %s</h2>\n' % displaypath
            ).encode("utf-8")
        )
        f.write(b"<hr>\n")
        f.write(b'<form ENCTYPE="multipart/form-data" method="post">')
        f.write(b'<input name="file" type="file"/>')
        f.write(b'<input type="submit" value="upload"/></form>\n')
        f.write(b"<hr>\n<ul>\n")
        for name in entries:
            fullname = os.path.join(path, name)
            displayname = linkname = name
            if os.path.isdir(fullname):
                displayname = name + "/"
                linkname = name + "/"
            if os.path.islink(fullname):
                displayname = name + "@"
            f.write(
                (
                    '<li><a href="%s">%s</a>\n'
                    % (quote(linkname), html.escape(displayname))
                ).encode("utf-8")
            )
        f.write(b'</ul>\n<hr>\n<small class="power">Powered By: Tony Pajamas | ')
        f.write(b'<a href="http://youtube.com/" target="_blank">')
        f.write(b"Smash that like</a>.</small>\n</body>\n</html>\n")

        length = f.tell()
        f.seek(0)
        self.send_response(200)
        self.send_header("Content-type", "text/html; charset=utf-8")
        self.send_header("Content-Length", str(length))
        self.end_headers()
        return f


class ThreadingHTTPServer(socketserver.ThreadingMixIn, http.server.HTTPServer):
    daemon_threads = True


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "port", action="store", default=8000, type=int, nargs="?",
        help="bind to this port (default: 8000)",
    )
    parser.add_argument(
        "--bind", "-b", default="0.0.0.0", metavar="ADDRESS",
        help="bind to this address (default: all interfaces)",
    )
    parser.add_argument(
        "--directory", "-d", default=os.getcwd(),
        help="serve this directory (default: current directory)",
    )
    args = parser.parse_args()

    handler = lambda *a, **k: SimpleHTTPRequestHandler(
        *a, directory=args.directory, **k
    )
    with ThreadingHTTPServer((args.bind, args.port), handler) as httpd:
        host, port = httpd.socket.getsockname()[:2]
        print("Serving HTTP on %s port %d (http://%s:%d/) ..." % (host, port, host, port))
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\nKeyboard interrupt received, shutting down.")
            sys.exit(0)


if __name__ == "__main__":
    main()
