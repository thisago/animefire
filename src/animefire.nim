import std/asyncdispatch
from std/htmlparser import parseHtml
from std/xmltree import items, attr, innerText
from std/os import createDir, fileExists, `/`, dirExists, existsOrCreateDir, sleep
from std/strformat import fmt
from std/strutils import replace
from std/uri import parseUri
from std/json import parseJson, `[]`, getStr
import std/osproc

from pkg/nimquery import querySelectorAll, querySelector

from pkg/unifetch import fetch
from pkg/util/forTerm import echoSingleLine
from pkg/util/forFs import escapeFs
from pkg/util/forStr import after


proc downloadFile(url, dest: string) =
  # https://github.com/thisago/kiwifyDownload/blob/master/src/kiwifyDownload.nim#L10
  if fileExists dest:
    echo fmt"Skipping existing file {dest}"
    return
  let
    cmd = fmt"""wget "{url}" -O "{dest}_tmp" && mv "{dest}_tmp" "{dest}" """ # windows?
    down = startProcess(
      cmd,
      options = {poStdErrToStdOut, poUsePath, poEvalCommand, poDaemon}
    )
  for line in down.lines:
    echoSingleLine line
  echo ""
  close down


proc main(playlistUrls: seq[string]; outDir: string; bestQuality = true): bool =
  ## Download all videos from AnimeFire
  discard existsOrCreateDir outDir
  for url in playlistUrls:
    let animeDir = outDir / url.parseUri.path.after("animes/").escapeFs
    if not dirExists animeDir:
      echo "Downloading ", animeDir
      createDir animeDir
      for a in url.fetch.waitFor.parseHtml.querySelectorAll(".div_video_list a.divNumEp"):
        let
          url = a.attr("href").replace("/animes/", "/video/")
          videos = parseJson waitFor fetch url
          videoUrl = (if bestQuality: videos["data"][^1] else: videos["data"][0])["src"].getStr
          name = url.after("video/") & ".mp4"
        echo "  Downloading ", name
        videoUrl.downloadFile animeDir / escapeFs name
    else:
      echo "Skipping " & animeDir

when isMainModule:
  import pkg/cligen
  dispatch main
