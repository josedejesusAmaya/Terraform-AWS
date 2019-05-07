# Lesson 3 - modules

everything in the same directory level becomes part of a module

modules can be used in two different ways:
- used in another tf file as "classes" of a library
- instantiated directly - with a specific state and set of variables

pattern:
- one main used with dynamic different states and vars (this lesson)
- one copy of main with hardcoded state and vars

modules can be loaded from the FS or from a git repository with git sha reference

How to use this:

Create prod env
```
ENV=prod ./terraform init
ENV=prod ./terraform apply
```

Create dev env
```
ENV=dev ./terraform init
ENV=dev ./terraform apply
```


There is an issue here: https://github.com/hashicorp/terraform/issues/15978