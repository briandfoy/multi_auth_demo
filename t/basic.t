use Mojo::Base -strict;
use lib qw(lib);

use Mojo::Util qw(b64_encode);
use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('MultiAuthDemo');

my $header_name = 'X-Api-Header';
my $path = '/api/hello';
my $auth_value = '1234';
my $encoded_password = b64_encode($auth_value) =~ s/\s+//gr;
diag( "encoded: $encoded_password" );

subtest 'ok' => sub {
	subtest 'token' => sub {
		$t
			->get_ok($path => { $header_name => $auth_value })
			->status_is(200)
			->json_is('/greeting'  => 'Hello')
			->json_is('/auth_type' => 'token');
	};

	subtest 'basic' => sub {
		$t
			->get_ok($path => { 'Authorization' => "basic $encoded_password" })
			->status_is(200)
			->json_is('/greeting' => 'Hello')
			->json_is('/auth_type' => 'basic');
	};
};

subtest 'not ok' => sub {
	my $status = '401';

	subtest 'neither' => sub {
		$t
			->get_ok($path)
			->status_is($status)
			->json_is('/status', $status)
			->json_like('/errors/0/message' => qr/No <\Q$header_name\E>/ )
			->json_like('/errors/1/message' => qr/No <Authorization>/ )
	};

	subtest 'token' => sub {
		$t
			->get_ok($path => { $header_name => "x$auth_value" })
			->status_is($status)
			->json_is('/status', $status)
			->json_like('/errors/0/message' => qr/is invalid/ )
			->json_like('/errors/1/message' => qr/No <Authorization>/ )
	};

	subtest 'basic' => sub {
		$t
			->get_ok($path => { 'Authorization' => "basic x$encoded_password" })
			->status_is($status)
			->json_is('/status', $status)
			->json_like('/errors/0/message' => qr/No <\Q$header_name\E>/ )
			->json_like('/errors/1/message' => qr/is invalid/ )
	};
};

done_testing();
