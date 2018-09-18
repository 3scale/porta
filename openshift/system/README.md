# OpenShift deployment

Follow the instructions in openshift templates repository:

https://github.com/3scale/openshift-templates/tree/master/system

```shell
cd 3scale
git clone git@github.com:3scale/openshift-templates.git
cd openshift-templates/system
cat README.md
```

# System Release as a part of AMP

1. Build the image

   ```shell
   make build DOCKERFILE=Dockerfile.on_prem NAME=amp VERSION=system-er2-pre1
   ```

2. Test the image

   ```shell
   make test NAME=amp VERSION=system-er2-pre1
   ```

3. Tag the image

   ```shell
   make tag NAME=amp VERSION=system-er2-pre1
   ```

4. Push the image

   ```shell
   make push NAME=amp VERSION=system-er2-pre1
   ```