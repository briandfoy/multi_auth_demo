package MultiAuthDemo::Plugin::OpenAPI;

use Mojo::Base 'Mojolicious::Plugin', -signatures;
use Mojo::Util qw(b64_decode);

sub register ($self, $app, $args) {
	my $swagger_file = $app->config->{openapi_spec_path}->[0];

	$app->plugin(
	  'OpenAPI' => {
		spec                 => $swagger_file,
		render_specification => 1,
		schema               => 'v3',
		security             => {
		  # these keys match the names in securitySchemes in openapi.yml .
		  # any of these that succeed let's OpenAPI stuff continue
		  api_token  => \&_check_api_token,
		  basic_auth => \&_check_basic_auth,
		},
	  }
	);
}

sub _check_api_token ($c, $definition, $scope, $cb) {
	$c->app->log->info( "In _check_api_token" );
	state $header_name = 'X-Api-Header';

	unless( exists $c->req->headers->to_hash->{$header_name} ) {
		return $c->$cb( "No <$header_name> header in request" )
	}

	# this header name has to match the one specified in the api_token
	# definition
	my $token = $c->req->headers->header($header_name);

	if( $token eq '1234' ) {
		$c->stash( auth_type => 'token' );
		return $c->$cb();
	} else {
		return $c->$cb("token is invalid");
	}
}

sub _check_basic_auth ($c, $definition, $scope, $cb) {
	$c->app->log->info( "$c" );
	$c->app->log->info( "In _check_basic_auth" );
	state $header_name = 'Authorization';

	if( ! exists $c->req->headers->to_hash->{$header_name} ) {
		return $c->$cb( "No <$header_name> header in request" )
	} elsif( $c->req->headers->header($header_name) !~ m/\Abasic\b/i ) {
		return $c->$cb( "<$header_name> value in request" )
	}

	my( $type, $encoded_password ) = split /\s+/, $c->req->headers->header('Authorization');
	my $password = b64_decode($encoded_password);

	if( $password eq '1234' ) { # MTIzNA==
		$c->stash( auth_type => 'basic' );
		return $c->$cb();
	} else {
		return $c->$cb("password is invalid");
	}
}

1;
