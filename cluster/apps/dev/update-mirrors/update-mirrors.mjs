#!/usr/bin/env zx

import { stat } from "fs/promises"
import { existsSync } from "fs"
import { parse as urlParse } from "url"
import { exec } from "child_process/promises"

const urls = Object.keys(process.env).reduce(
  (acc, key) =>
    key.startsWith("GIT_REMOTE_")
      ? acc.concat(urlParse(process.env[key]))
      : acc,
  []
)

const isDirectory = async (pathname) => {
  try {
    return (await stat(pathname)).isDirectory()
  } catch (error) {
    return false
  }
}

const WORKDIR = process.env.WORKING_DIRECTORY || __dirname
if (WORKDIR !== __dirname) {
  process.chdir(WORKDIR)
}

for (const url of urls) {
  const { pathname: fullPathname, href } = url
  const [ownerName, repoNameWithPossibleExtension] = fullPathname
    .substring(1)
    .split("/")
  const repoName = path.parse(repoNameWithPossibleExtension).name
  const repoPath = path.join(WORKDIR, ownerName, repoName)
  if (existsSync(repoPath)) {
    if (isDirectory(repoPath)) {
      console.debug(`git -C ${repoPath} remote update -p`)
      await exec("git", ["-C", repoPath, "remote", "update", "-p"])
    } else {
      throw Error(`${repoPath} exists but is not a directory.`)
    }
  } else {
    const parentDirectory = path.join(WORKDIR, ownerName)
    console.debug(
      `mkdir -p ${parentDirectory}`,
      `git -C ${parentDirectory} clone --mirror ${href} ${repoName}`
    )
    await exec("mkdir", ["-p", parentDirectory])
    await exec("git", [
      "-C",
      parentDirectory,
      "clone",
      "--mirror",
      href,
      repoName,
    ])
  }
}

console.info("Updates complete.")
