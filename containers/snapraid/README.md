# SnapRAID

This SnapRAID image uses [the runner](https://github.com/Chronial/snapraid-runner) to automate the backup syncs.

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
  curl -d "Starting..." ntfy.sh/mytopic

POST_COMMANDS_SUCCESS: |-
  curl -d "Backup successful 😀" ntfy.sh/mytopic

POST_COMMANDS_FAILURE: |-
  /my/scripts/mail-failure.sh

POST_COMMANDS_INCOMPLETE: |-
  /my/scripts/mail-incomplete.sh

POST_COMMANDS_EXIT: |-
  docker start my_container
```
