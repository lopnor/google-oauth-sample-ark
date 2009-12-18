package AuthSub::Model::AuthSub;
use Ark 'Model::Adaptor';

__PACKAGE__->config(
    class => 'Net::Google::AuthSub'
);

1;
