# Gogs Deployment with PostgreSQL on Kubernetes

Before anything else I want to give a shoutout to my personal hero and role model, [Kelsey Hightower](https://twitter.com/kelseyhightower) [github](https://github.com/kelseyhightower) [youtube](https://www.youtube.com/user/MadHatterConfigMgmt). I got lucky enough to catch one of his demos in Charleston and speak to him after which was what inspired me to start open sourcing some projects to share with the community. Check out some of his videos sometime, I guarantee they'll be some of the most entertaining technical talks you've witnessed.

[Gogs](https://gogs.io) is a [painless self-hosted Git service.](https://github.com/gogits/gogs/tree/master)

[PostgreSQL](https://www.postgresql.org/) is an [advanced object-relational database management system](https://github.com/postgres/postgres) that supports an extended subset of the SQL standard, including transactions, foreign keys, subqueries, triggers, user-defined types and functions.

Be sure to check out the [drone.io deployment repo](https://github.com/stevenaldinger/k8s-drone) after launching this to add instant CI/CD to your new cluster in one command!

# Deploying Gogs and Postgres

## Prerequisites

If you don't have a Kubernetes cluster to work with yet, check out my [local-kubernetes-bootstrap](https://github.com/stevenaldinger/local-kubernetes-bootstrap) repo to get started locally with Minikube or go dive into [Google Container Engine](https://cloud.google.com/container-engine/) for a hosted solution.

## Quickstart

`kubectl apply -f ./k8s`

## Port forwarding

Once the pods are created, forward port 3000 (or any other) on your local machine to port 3000 of the `gogs` pod to make the web UI accessible in your browser. Two users will already be available, `gogs` (which has an example repository created as well and is intended to be used by you for instant exploring and [drone.io continuous integration and deployment](https://github.com/stevenaldinger/k8s-drone)) and `drone` which is intended to work as a service account.

`kubectl port-forward gogs-0 -n vcs 3000:3000`

Navigate to [http://localhost:3000](http://localhost:3000) to begin using your new `Gogs` git service.

### Users

```
user: gogs
pass: gogs
email: gogs@gogs.io

user: drone
pass: drone
email: drone@drone.io
```

## Contributing

Any contributions are extremely welcome and appreciated. If you see ways to improve the deployments and know how to make it happen, open up a pull request with a brief description of what you did and I'll gladly take a look and merge it in. If you see ways to improve the deployments and don't know how to make it happen, don't be shy about creating a new issue and I'll try to tackle it when I have some time.

Any questions you come up with are also important contributions if they're made publicly where others can stumble across them. I'm still learning so may not have a good answer for you immediately but I promise you won't be ignored.

# TODO / Known Issues:

1. Using a `secret` to set the `gogs` database password makes login fail for some reason. For the time being the password is just deployed in a `configmap`, although this is insecure.
2. Attempting to use a proper `readinessProbe` on postgres container always fails with: `FATAL:  role "root" does not exist`. This needs a flag to run it as the `gogs` user.
3. Make database seeding configurable and in an init-container. That'll allow for random password generation on each deployment to make it more secure by default and also allow people to choose their own initial username.
4. Add an example `.drone.yml` to the example repo
