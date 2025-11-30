function handler(event) {
  var request = event.request;
  var uri = request.uri;
  // If the URI is longer than 1 char (not the site root) and ends with a slash
  // -> redirect to the non-trailing-slash canonical URL
  if (uri.length > 1 && uri.charAt(uri.length - 1) === '/') {
    var newUri = uri.substring(0, uri.length - 1);
    var qs = '';
    if (request.querystring && request.querystring.length > 0) {
      qs = '?' + request.querystring;
    }
    var host = '';
    if (request.headers && request.headers.host) {
      host = request.headers.host.value;
    }

    return {
      statusCode: 301,
      statusDescription: 'Moved Permanently',
      headers: {
        'location': { value: 'https://' + host + newUri + qs }
      }
    };
  }

  // If the URI does NOT end with a slash, and appears to be a "directory" (no file extension),
  // rewrite the request internally to point to index.html so S3 will serve the directory index.
  // e.g. request for /foo -> origin request for /foo/index.html
  // We consider a path to be a directory when it has length > 1 and contains no dot.
  if (uri.length > 1 && uri.indexOf('.') === -1) {
    // avoid double appending if already rewritten
    if (!uri.endsWith('/index.html')) {
      request.uri = uri + '/index.html';
    }
    return request;
  }

  return request;
}
