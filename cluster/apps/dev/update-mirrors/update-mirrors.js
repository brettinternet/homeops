#!/usr/bin/env zx

import * as fs from "fs/promises"
import * as url from "url"

const urls = Object.keys($.env).reduce(
  (acc, key) =>
    key.startsWith("GIT_REMOTE_") ? acc.concat(url.parse($.env[key])) : acc,
  []
)

cd($.env.WORKING_DIRECTORY)

for (const url of urls) {
  const { pathname: fullPathname, href } = url
  const pathname = fullPathname.substring(1)
  if ((await fs.stat(pathname)).isDirectory()) {
    await $`git -C ${pathname} remote update -p`
  } else {
    const parentDirectory = pathname.split("/")[0]
    await $`mkdir -p ${parentDirectory} && git -C ${parentDirectory} clone --mirror ${href}`
  }
}

console.log(chalk.green("Updates complete."))
