# SousChef

An example update server for binary executables create with bakeware

## Using

SousChef currently functions as a JSON API with a few particularly useful endpoints:

* `/api/check/:exec_name` - Check your version against the latest version on the update server. Requires `version` argument to be passed. If you are out of date, `%{status: "update", url: "some-url"}` will be returned
  * `curl sous-chef.jonjon.dev/api/check/hello_world?version=0.0.1`
  


## Deploying

This is currently deployed with Gigalixir. Since it is a folder of a repo, `git subtree` must be used. If you're setup and authorized, you can use the following commands to deploy:

**Deploy normally**

```sh
git subtree push --prefix sous_chef gigalixir master
```

**Deploy "fresh"**

If you change the git history (like a rebase) you'll have to clean the gigalixir cache

```sh
git -c http.extraheader="GIGALIXIR-CLEAN: true" subtree --prefix sous_chef push gigalixir master
```
