

# Dockerfail to Dockerfile

## Purpose

This is the demo repository for the talk "From Dockerfail to Dockerfile". It is based on the [wordsmith](https://github.com/dockersamples/wordsmith) repository. The purpose is to show how teams can start from minimal dockerized app to a production-ready deployment.

> Disclaimer: the code is intentionally left agnostic to tools and vendors, and is NOT suited for production use.

Code is divided in 11 folders, each bringing an improvement on the previous one.

00. minimal viable container running wordsmith demo
01. syntaxic check of Dockerfile with hadolint
02. semantic checks of resulting Docker image with container-structure-test
03. speed and network gains with cache good practices
04. security and image size fixes with multi stage Dockerfile
05. storing secrets away from code
06. auditable track of dependencies
07. increasing resiliency with healthchecks
08. splitting demo app in multi-container deployment
09. signing images to enforce trusted origin
10. doing it all without Docker tooling

## Requirements

- shell
- docker 20+
- a docker hub account to push images (free)
- [ggshield](https://docs.gitguardian.com/ggshield-docs/reference/install) (client with valid API key)
- [snyk](https://snyk.io/) (connected via docker scan --login)

### Configuration

rename/copy `.env-dist` to `.env`

open `.env` to complete configuration
```
export GITGUARDIAN_API_KEY=<xyz>
export REGISTRY=dockerfail
```

> Apple M1 Chip: you need to force platform type like this:
`export DOCKER_DEFAULT_PLATFORM=linux/arm64`

### Usage

1. choose between on of the 10 "dockerfails" to run the demo:

```bash
cd <dockerfail folder>
./build-ship-run.sh
```

2. check running containers

```
docker ps
OR
docker service ls
```

3. study diffs from one stage to the other folders to understand how each step fixes the previous defect. For instance:

`diff 00-base 01-hadolint`

## Todo

- [ ] set image tags by content and not by timestamp
- [ ] set labels on all resources to clean more easily

## Contributing

There are more Dockerfails out there! If you feel like contributing, feel free to submit a PR.

## License

<a rel="license" href="http://creativecommons.org/licenses/by-nc/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-nc/4.0/">Creative Commons Attribution-NonCommercial 4.0 International License</a>.

