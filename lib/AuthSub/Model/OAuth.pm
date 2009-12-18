package AuthSub::Model::OAuth;
use Ark 'Model';
use Net::Google::DataAPI::Auth::OAuth;
use AuthSub;
use YAML;
use URI;

my %request_token;
my %access_token;

my $config = YAML::LoadFile(AuthSub->path_to('config.yaml'));
__PACKAGE__->config(
    consumer_key => $config->{consumer_key},
    consumer_secret => $config->{consumer_secret},
    scope => ref $config->{scope} ? $config->{scope} : [ $config->{scope} ],
);

sub get_authorize_token_url {
    my ($self, %args) = @_;
    if ($args{callback} && ! ref $args{callback} ne 'URI') {
        $args{callback} = URI->new("$args{callback}");
    }
    my $oauth = $self->_get_instance(%args);
    $oauth->get_request_token or die;
    $request_token{$oauth->request_token} = $oauth->request_token_secret;
    $oauth->get_authorize_token_url;
}

sub get_access_token {
    my ($self, %args) = @_;
    my $oauth = $self->_get_instance;
    $oauth->request_token($args{request_token});
    $oauth->request_token_secret($request_token{$args{request_token}});
    $oauth->get_access_token({verifier => $args{verifier}});
    $access_token{$oauth->access_token} = $oauth->access_token_secret;
    return $oauth->access_token;
}

sub get_auth {
    my ($self, $token) = @_;
    my $auth = $self->_get_instance;
    $auth->access_token($token);
    $auth->access_token_secret($access_token{$token});
    return $auth;
}

sub _get_instance {
    my ($self, %args) = @_;
    return Net::Google::DataAPI::Auth::OAuth->new(
        %{$self->config},
        %args,
    );
}

1;
