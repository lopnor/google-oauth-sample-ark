? use Encode;
<html>
<head>
<meta http_equiv="Content-Type" content="text/html; charset=UTF-8" />
</head>
<body>
? if (my $ss = $c->stash->{spreadsheets}) {
<ul>
?   for my $sheet (@{$ss}) {
    <li><?= $sheet->title ?></li>
?   }
</ul>
? } else {
<a href="<?= $c->uri_for('/authsub') ?>">AuthSub</a>
<a href="<?= $c->uri_for('/oauth') ?>">OAuth</a>
? }
</body>
</html>
