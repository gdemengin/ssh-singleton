from pathlib import Path
import sys

from http.server import BaseHTTPRequestHandler, HTTPServer

class StoreHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        Path(f'.{self.path}').write_text('')
        response=b'\rOK ack succesfully sent to client server\n'
        self.send_response(200)
        self.send_header("Content-type", "text/html")
        self.send_header("Content-length", len(response))
        self.end_headers()
        self.wfile.write(response)

server = HTTPServer(('', int(sys.argv[1])), StoreHandler)
server.serve_forever()
