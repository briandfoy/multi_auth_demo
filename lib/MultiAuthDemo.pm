package MultiAuthDemo;
use Mojo::Base 'Mojolicious', -signatures;

sub startup ($self) {
	$self->plugin('DefaultHelpers');
	my $config = $self->plugin('NotYAMLConfig');
	$self->plugin('MultiAuthDemo::Plugin::OpenAPI');
	$self->secrets($config->{secrets});

	my $r = $self->routes;
	my $api = $r->any('/api')->to( controller => 'Main' );
	$api->get('/hello')->to( action => 'hello' );
}

1;
