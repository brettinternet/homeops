# https://gitolite.com/gitolite/basic-admin#appendix-1-bringing-existing-repos-into-gitolite
# https://stackoverflow.com/questions/5767850/git-on-custom-ssh-port

#!/bin/sh

set -- /usr/sbin/sshd -D

# Setup SSH HostKeys if needed
for algorithm in rsa dsa ecdsa ed25519
do
  keyfile=/etc/ssh/keys/ssh_host_${algorithm}_key
  [ -f $keyfile ] || ssh-keygen -q -N '' -f $keyfile -t $algorithm
  grep -q "HostKey $keyfile" /etc/ssh/sshd_config || echo "HostKey $keyfile" >> /etc/ssh/sshd_config
done
# Disable unwanted authentications
perl -i -pe 's/^#?((?!Kerberos|GSSAPI)\w*Authentication)\s.*/\1 no/; s/^(PubkeyAuthentication) no/\1 yes/' /etc/ssh/sshd_config
# Disable sftp subsystem
perl -i -pe 's/^(Subsystem\ssftp\s)/#\1/' /etc/ssh/sshd_config

# Fix permissions at every startup
chown -R git:git ~git

# Setup gitolite admin
if [ ! -f ~git/.ssh/authorized_keys ]; then
  if [ -n "$SSH_KEY" ]; then
    [ -n "$SSH_KEY_NAME" ] || SSH_KEY_NAME=admin
    echo "$SSH_KEY" > "/tmp/$SSH_KEY_NAME.pub"
    su - git -c "gitolite setup -pk \"/tmp/$SSH_KEY_NAME.pub\""
    rm "/tmp/$SSH_KEY_NAME.pub"
  else
    echo "You need to specify SSH_KEY on first run to setup gitolite"
    echo "You can also use SSH_KEY_NAME to specify the key name (optional)"
    echo 'Example: docker run -e SSH_KEY="$(cat ~/.ssh/id_rsa.pub)" -e SSH_KEY_NAME="$(whoami)" jgiannuzzi/gitolite'
    exit 1
  fi
# Check setup at every startup
else
  su - git -c "gitolite setup"
fi

exec "$@"
