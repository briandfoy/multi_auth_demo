package MultiAuthDemo::Controller::Main;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub hello ($c) {
	$c->app->log->info( "$c" );
	$c->render( json => {greeting => 'Hello', auth_type => $c->stash('auth_type') } );
}

1;
