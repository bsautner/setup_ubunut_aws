export USER="ben"

mkdir .ssh
chmod 700 .ssh
touch .ssh/authorized_keys
chmod 600 .ssh/authorized_keys
echo "Done setup paste the pub key into above"

git config --global user.email $USER
git config --global user.name "Benjamin Sautner"


apt-get -y install pass
pass init $USER
pass git init


