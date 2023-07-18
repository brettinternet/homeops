#!/usr/bin/env zx

/**
 * Scrape helm-release.yaml files, find subdomains and fetch them to ensure
 * 404 responses are received from URLs that should be private.
 */

// Glob and YAML are already available when run with google/zx
import Promise from "bluebird"
import _ from "lodash"

const isDev = process.env.NODE_ENV === "development"

const searchFilesGlob = ["../kubernetes/**/helm-release.yaml"]
const subdomainRegex =
  /\ \"(?<subdomain>[A-Za-z0-9\-]+)*\.\$\{PUBLIC_DOMAIN\}/gi
const externalDnsAnnotationRegex =
  /external-dns\.home\.arpa\/enabled\: \"true\"/gi

/**
 * Match subdomain and extract named group when external DNS annotation is not present
 * This should compare single documents only, and not files which may
 * contain multiple YAML documents.
 */
const matchExternalSubdomain = (yamlDocument) => {
  const subdomainMatches = Array.from(yamlDocument.matchAll(subdomainRegex))
  const externalDnsMatches = Array.from(
    yamlDocument.matchAll(externalDnsAnnotationRegex)
  )
  if (!externalDnsMatches[0]) {
    return subdomainMatches
  }
  return []
}

/**
 * We want 404s from internal endpoints
 */
const check404 = async (subdomain) => {
  const url = `https://${subdomain}.${process.env.PUBLIC_DOMAIN}`
  let is404 = false
  try {
    const res = await fetch(url, { method: "GET" })
    is404 = res.status === 404
  } catch (err) {
    is404 = err.code === "ENOTFOUND"
  }
  return {
    url,
    is404,
  }
}

/**
 * Create GitHub issue as notification
 * https://docs.github.com/en/rest/issues/issues#create-an-issue
 */
const createIssue = async () => {
  const issue = {
    owner: "brettinternet",
    repo: "cluster",
    title: "Exposed endpoint",
    body: "One of your subdomains has been unintentionally exposed to the internet.",
  }
  if (isDev) {
    console.error(`${issue.title}:`, issue.body)
  } else {
    if (!process.env.GITHUB_SECRET) {
      throw Error("'process.env.GITHUB_SECRET' must be defined.")
    }

    await fetch(
      `https://api.github.com/repos/${issue.owner}/${issue.repo}/issues`,
      {
        method: "POST",
        headers: {
          Accept: "application/vnd.github+json",
          Authorization: `Bearer ${process.env.GITHUB_SECRET}`,
        },
        body: {
          title: issue.title,
          body: issue.body,
        },
      }
    )
  }
}

// Get all release files
await Promise.resolve(glob(searchFilesGlob))
  // Read release file content
  .map((filepath) => fs.readFile(filepath, "utf8"))
  // Separate YAML documents from single file
  .reduce(
    (acc, content) =>
      acc.concat(YAML.parseAllDocuments(content).map((doc) => doc.toString())),
    []
  )
  // Collect subdomain matches
  .map(matchExternalSubdomain)
  // Flatten and map subdomain from named group
  .reduce(
    (acc, fileMatch) => acc.concat(fileMatch.map((m) => m.groups.subdomain)),
    []
  )
  // Make unique
  .then(_.uniq)
  // Fetch each URL and map result
  .tap(() => {
    if (!process.env.PUBLIC_DOMAIN) {
      throw Error("'process.env.PUBLIC_DOMAIN' must be defined.")
    }
  })
  .map(check404)
  .tap(console.debug)
  // Ensure every result has 404
  .then((url404s) => url404s.every(({ is404 }) => is404))
  // Notify if every result is not 404
  .tap((every404) => {
    if (!every404) {
      createIssue()
    } else {
      console.debug("All private URLs fetched a 404.")
    }
  })
  .error(console.error)
