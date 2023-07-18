import { stat } from "node:fs/promises"
import { existsSync } from "node:fs"
import { dirname, parse as pathParse, join as pathJoin } from "node:path"
import { parse as urlParse, fileURLToPath } from "node:url"
import { promisify } from "node:util"
import { exec as execSync } from "node:child_process"

const exec = promisify(execSync)
const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)

const WORKDIR = process.env.WORKING_DIRECTORY || __dirname
if (WORKDIR !== __dirname) {
  process.chdir(WORKDIR)
}

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

const removeFalsy = (obj) => {
  const filteredObj = {}
  Object.keys(obj).forEach((key) => {
    if (obj[key]) {
      filteredObj[key] = obj[key]
    }
  })
  return filteredObj
}

const logResult = (result) => {
  const logs = removeFalsy(result)
  if (Object.keys(logs).length !== 0) {
    console.debug(logs)
  }
}

for (const url of urls) {
  const { pathname: fullPathname, href } = url
  const [ownerName, repoNameWithPossibleExtension] = fullPathname
    .substring(1)
    .split("/")
  const repoName = pathParse(repoNameWithPossibleExtension).name
  const repoPath = pathJoin(WORKDIR, ownerName, repoName)
  if (existsSync(repoPath)) {
    if (isDirectory(repoPath)) {
      console.debug(`git -C ${repoPath} remote update -p`)
      const gitResult = await exec(`git -C ${repoPath} remote update -p`)
      logResult(gitResult)
    } else {
      throw Error(`${repoPath} exists but is not a directory.`)
    }
  } else {
    const parentDirectory = pathJoin(WORKDIR, ownerName)
    console.debug(`mkdir -p ${parentDirectory}`)
    const mkdirResult = await exec(`mkdir -p ${parentDirectory}`)
    logResult(mkdirResult)
    console.debug(
      `git -C ${parentDirectory} clone --mirror ${href} ${repoName}`
    )
    const gitResult = await exec(
      `git -C ${parentDirectory} clone --mirror ${href} ${repoName}`
    )
    logResult(gitResult)
  }
}

console.info("Updates complete.")
