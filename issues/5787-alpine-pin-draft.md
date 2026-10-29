Title: docker: pin the final alpine base image

The final stage of the release `Dockerfile` (and `dev.Dockerfile`) uses a bare
`FROM alpine`, with no version tag or digest (master @ c03d36598):

- https://github.com/lightningnetwork/lnd/blob/c03d365984fe7e4e53400ef6c6017622daffa702/Dockerfile#L22
- https://github.com/lightningnetwork/lnd/blob/c03d365984fe7e4e53400ef6c6017622daffa702/dev.Dockerfile#L28

`.github/workflows/docker.yml` builds this file for every release tag and for
the daily `lightninglabs/lnd` image. So each build runs on whatever
`alpine:latest` is that day. Two builds of the same lnd tag can ship different
Alpine releases, a new Alpine major can change the published image without any
lnd change, and the base layer of a given image can't be tied back to the repo.
The builder stage is already pinned by version (`golang:1.27.3-alpine`).

Proposal: pin the final stage, at minimum to an Alpine release
(`alpine:3.x`), ideally to that release's multi-arch index digest
(`alpine:3.x@sha256:...`). An index digest resolves per platform, so it works
for both `linux/amd64` and `linux/arm64`, which was the concern raised on the
earlier attempt, #5753 (closed; it pinned only the builder images). The pin
would be bumped alongside the regular Go version bumps.

Background: #5787 (distroless images, closed not planned).
