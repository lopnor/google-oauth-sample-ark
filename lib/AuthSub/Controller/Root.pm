package AuthSub::Controller::Root;
use Ark 'Controller';
use Net::Google::AuthSub;
use Net::Google::DataAPI::Auth::AuthSub;
use Net::Google::Spreadsheets;

has '+namespace' => default => '';

# default 404 handler
sub default :Path :Args {
    my ($self, $c) = @_;

    $c->res->status(404);
    $c->res->body('404 Not Found');
}

sub index :Path :Args(0) {
    my ($self, $c) = @_;
    my $auth;
    if (my $token = $c->session->get('token')) {
        $auth = $c->model('AuthSub')->get_auth($token);
    } elsif (my $access_token = $c->session->get('access_token')) {
        $auth = $c->model('OAuth')->get_auth($access_token);
    }
    if ($auth) {
        my $service = Net::Google::Spreadsheets->new( auth => $auth );
        my @ss = $service->spreadsheets;
        $c->stash->{spreadsheets} = \@ss;
    }
}

sub authsub :Local {
    my ($self, $c) = @_;
    return $c->redirect( 
        $c->model('AuthSub')->request_token(
            callback => $c->uri_for('/token')
        )
    );
}

sub oauth :Local {
    my ($self, $c) = @_;
    return $c->redirect( 
        $c->model('OAuth')->get_authorize_token_url(
            callback => $c->uri_for('/token')
        )
    );
}

sub token :Local {
    my ($self, $c) = @_;
    if (my $authsub_token = $c->req->param('token')) {
        my $token = $c->model('AuthSub')->session_token($authsub_token);
        $c->session->set(token => $token);
    } else {
        my $req_token = $c->req->param('oauth_token');
        my $verifier = $c->req->param('oauth_verifier');
        $req_token && $verifier 
            or return $c->redirect($c->uri_for('/'));
        my $access_token = $c->model('OAuth')->get_access_token(
            request_token => $req_token,
            verifier => $verifier,
        );
        $c->session->set(access_token => $access_token);
    }
    $c->redirect($c->uri_for('/'));
}

sub end :Private {
    my ($self, $c) = @_;
    unless ($c->res->body || $c->res->code =~ /^3\d\d/) {
        $c->forward($c->view('MT'));
    }
}

1;
