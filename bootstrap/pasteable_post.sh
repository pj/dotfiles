EOF

cat $HOME/bootstrap-b64 | base64 -d > $HOME/bootstrap
chmod u+x $HOME/bootstrap
$HOME/bootstrap