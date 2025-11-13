# Mojoilicious OpenAPI with multiple auth modes

I have a project where both token and HTTP basic auth are used. Send either
one and it all works out.

The [/openapi.yml] file needs to define all of the auth methods, and Mojo has to
handle the auth. In this example, that's in [lib/MultiAuthDemo/Plugin/OpenAPI.pm].

## Run the tests

	$ perl t/basic.t

## Run the server

The basic auth password and the token are both `1234`. For basic auth, the
Base64 version is `MTIzNA==`:

	$ morbo script/multi_auth_demo
	Web application available at http://127.0.0.1:3000

	$ curl -H 'Authorization: basic MTIzNA==' http://localhost:3000/api/hello
	{"auth_type":"basic","greeting":"Hello"}

	$ curl -H 'X-Api-Header: 1234' http://localhost:3000/api/hello
	{"auth_type":"token","greeting":"Hello"}

See it fail:

	$ curl -H 'Authorization: basic xMTIzNA==' http://localhost:3000/api/hello
	{"errors":[{"message":"No <X-Api-Header> header in request","path":"\/security\/0\/api_token"},{"message":"password is invalid","path":"\/security\/1\/basic_auth"}],"status":401}

	$ curl -H 'X-Api-Header: 12345' http://localhost:3000/api/hello
	{"errors":[{"message":"token is invalid","path":"\/security\/0\/api_token"},{"message":"No <Authorization> header in request","path":"\/security\/1\/basic_auth"}],"status":401}

Both at the same time, where either is sufficient:

	$ curl -H 'X-Api-Header: 1234' -H 'Authorization: basic MTIzNA==' http://localhost:3000/api/hello
	{"auth_type":"basic","greeting":"Hello"}

This tiem the basic auth password is wrong, so `token` wins:

	$ curl -H 'X-Api-Header: 1234' -H 'Authorization: basic xMTIzNA==' http://localhost:3000/api/hello
	{"auth_type":"token","greeting":"Hello"}

Both don't have to work at the same time. I just didn't do anything to prevent
it, such as failing if both headers are present.
