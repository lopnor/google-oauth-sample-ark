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
        my $authsub = Net::Google::AuthSub->new;
        $authsub->auth(undef, $token);
        $auth = Net::Google::DataAPI::Auth::AuthSub->new(
            authsub => $authsub,
        );
    } elsif (my $access_token = $c->session->get('access_token')) {
        my $oauth = $c->model('OAuth');
        $auth = $oauth->get_auth($access_token);
    }
    if ($auth) {
        my $service = Net::Google::Spreadsheets->new( auth => $auth );
        my @ss = $service->spreadsheets;
        $c->stash->{spreadsheets} = \@ss;
    }
}

sub authsub :Local {
    my ($self, $c) = @_;

    my $authsub = Net::Google::AuthSub->new;
    return $c->redirect(
        $authsub->request_token(
            $c->uri_for('/token'),
            'http://spreadsheets.google.com/feeds/',
            secure => 0,
            session => 1,
        )
    );
}

sub oauth :Local {
    my ($self, $c) = @_;
    
    my $oauth = $c->model('OAuth');
    return $c->redirect(
        $oauth->get_authorize_token_url
    );
}

sub token :Local {
    my ($self, $c) = @_;
    if (my $authsub_token = $c->req->param('token')) {
        my $authsub = Net::Google::AuthSub->new;
        $authsub->auth(undef, $authsub_token);
        my $session_token = $authsub->session_token;
        $c->session->set(token => $session_token);
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
