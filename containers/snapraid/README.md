# SnapRAID

This [SnapRAID](https://www.snapraid.it/) image uses a python [runner](https://github.com/Chronial/snapraid-runner) to automate the backup syncs. Curl and dumb-init entrypoint are also available.

```sh
docker create -d \
  -v /mnt:/mnt \
  # https://github.com/amadvance/snapraid/blob/master/snapraid.conf.example
  -v snapraid.conf:/config/snapraid.conf
  # https://github.com/Chronial/snapraid-runner/blob/master/snapraid-runner.conf.example
  -v snapraid-runner.conf:/config/snapraid-runner.conf
  -e POST_COMMANDS_SUCCESS "curl -d 'Backup successful 😀' ntfy.sh/mytopic"
  --name snapraid
  ghcr.io/brettinternet/snapraid
```

Also available in the `entrypoint.sh` are slots for pre and post commands:

```yaml
PRE_COMMANDS: |-
  curl -d "Oh boy, here we go again..." https://healthchecks.io/start

POST_COMMANDS_SUCCESS: |-
  curl -d "We backed it up!" ntfy.sh/mytopic

POST_COMMANDS_FAILURE: |-
  /config/mail-failure.sh

POST_COMMANDS_INCOMPLETE: |-
  /config/uh-oh.sh

POST_COMMANDS_EXIT: |-
  docker start my_container
```
