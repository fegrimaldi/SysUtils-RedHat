def application(environ,start_response):
	status = '200 OK'
	html = '''
		<!DOCTYPE html>
		<html lang="en">
			<head>
				<meta charset="UTF-8">
				<meta name="viewport" content="width=device-width, initial-scale=1.0">
				<title>WSGI Test</title>
			</head>
			<body>
				<h1>Hello, World!</h1>
				<h2>WSGI is operating nominally.</h2>
			</body>
		</html>'''
	response_header = [('Content-type','text/html')]
	start_response(status,response_header)
    return [bytes(html, 'utf-8')]