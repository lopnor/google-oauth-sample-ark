package AuthSub::Model::AuthSub;
use Ark 'Model';
use AuthSub;
use Net::Google::AuthSub;
use Net::Google::DataAPI::Auth::AuthSub;

sub session_token {
    my ($self, $token) = @_;
    my $authsub = $self->_get_instance;
    $authsub->auth(undef, $token);
    return $authsub->session_token;
}

sub request_token {
    my ($self, %args) = @_;

    my $authsub = $self->_get_instance;
    return $authsub->request_token(
        $args{callback},
        'http://spreadsheets.google.com/feeds/',
        secure => 0,
        session => 1,
    );
}

sub get_auth {
    my ($self, $token) = @_;
    my $authsub = $self->_get_instance;
    $authsub->auth(undef, $token);
    return Net::Google::DataAPI::Auth::AuthSub->new(
        authsub => $authsub
    );
}

sub _get_instance {
    my ($self) = @_;
    Net::Google::AuthSub->new;
}

1;
