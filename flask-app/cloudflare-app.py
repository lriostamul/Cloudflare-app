from flask import Flask, request, jsonify, render_template_string

app = Flask(__name__)

@app.route('/')
def headers():
    return jsonify(dict(request.headers))

@app.route('/protected')
def protected():
    headers = dict(request.headers)
    html_template = """
    <html>
        <head><title>Protected Path </title></head>
        <body>
            <h1 style="color: darkred;">Protected Path</h1>
            <pre>{{ headers | tojson(indent=2) }}</pre>
        </body>
    </html>
    """
    return render_template_string(html_template, headers=headers)

if __name__ == '__main__':
    context = (
        '/etc/letsencrypt/live/cloudflare-app.tamulsecurity.com/fullchain.pem',
        '/etc/letsencrypt/live/cloudflare-app.tamulsecurity.com/privkey.pem'
    )
    app.run(host='0.0.0.0', port=443, ssl_context=context)