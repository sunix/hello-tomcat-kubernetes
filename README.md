# Hello tomcat
A hello world tomcat application to be deployed to Kubernetes.

I am proposing several approaches:

1. Minikube with Dockerfile and YAML files
2. Minikube with JKube
3. Openshift (Red Hat Developer Sandbox) with JKube


## Prerequisites
### Minikube
You will need the following to run it with Minikube:
- `minikube` installed and running on your computer
- `minikube` ingress addon enabled

      $ minikube addons enable ingress

### Docker or podman
For the Dockerfile/YAML approach, `docker` or `podman` is required.

### To push to Quay.io
- create an account in https://quay.io
- create a repo `quay.io/yourusername/hello-tomcat`
- replace in the following, adapt `quay.io/sunix/hello-tomcat` with `quay.io/sunix/hello-tomcat`.
- login into `quay.io`

      $ docker login quay.io



## With Dockerfiles and YAML files
### Dockerfile
Build the war

    $ mvn clean install
    $ ls target |grep war
    hello-tomcat.war

Build the container image

    $ docker build -f src/main/docker/Dockerfile -t quay.io/sunix/hello-tomcat .
    
Test:

    $ docker run -p 8888:8080 quay.io/sunix/hello-tomcat

Try it: http://localhost:8888

Push the container image to the registry

    $ docker push quay.io/sunix/hello-tomcat


### YAML
Update the docker image in `kubernetes.yaml` file.

To deploy in Minikube:

    $ kubectl apply -f kubernetes.yaml

Get the URL

    $ minikube service hellotomcat-service --url


### Ingress
Problem with `nodeport` is that
- either you specify a port... but what if it conflicts?
- you let it choose for you ... but it's random

Let's use the ingress which is the most advanced way to expose a service

Excellent blog post for the difference between `nodeport`,`loadbalancer` and `ingress`: https://medium.com/google-cloud/kubernetes-nodeport-vs-loadbalancer-vs-ingress-when-should-i-use-what-922f010849e0

Replace in `ingress.yaml` the host with the result of

    $ echo $(minikube ip).nip.io

Apply

    $ kubectl apply -f ingress.yaml
    $ kubectl get ingress
    NAME                  CLASS    HOSTS                   ADDRESS          PORTS   AGE
    hellotomcat-ingress   <none>   192.168.99.116.nip.io   192.168.99.116   80      16s

Try it with the host URL.

### Scale
update `replicas` to 5 in `kubernetes.yaml`

    $ kubectl apply -f kubernetes.yaml

observe the creation and deployment of the 5 pods

    $ kubectl get pods

### Clean up

    $ kubectl delete ingress hellotomcat-ingress
    $ kubectl delete service hellotomcat-service
    $ kubectl delete deployment hellotomcat

### Other useful commands

To force redeployment (for instance if you have rebuilt the container image):

    $ kubectl replace --force -f kubernetes.yaml



## With JKube
With JKube it is a lot simpler: just add a plugin in `pom.xml`
### Prerequisites
We will use the docker daemon installed in the minikube

    $ eval $(minikube -p minikube docker-env)

or if you use podman

    $ eval $(minikube -p minikube podman-env)

### Adding the JKube plugin
In `pom.xml` add in the build section:

    <plugins>
      <plugin>
        <groupId>org.eclipse.jkube</groupId>
        <artifactId>kubernetes-maven-plugin</artifactId>
        <version>1.7.0</version>
      </plugin>
    </plugins>

and just run


    $ mvn clean install k8s:build k8s:resource k8s:apply


### Ingress
To also create an ingress:
In `pom.xml` properties section:

    <jkube.createExternalUrls>true</jkube.createExternalUrls>

We still have to specify the domain to be used:

    $ mvn clean install k8s:build k8s:resource -Djkube.domain=$(minikube ip).nip.io k8s:apply


### Scale
Add to pom.xml

    <jkube.replicas>10</jkube.replicas>

Give it a try:

    $ mvn k8s:resource -Djkube.domain=$(minikube ip).nip.io k8s:apply

### Clean up

    $ mvn k8s:undeploy

## The Red Hat Developer Sandbox

### Prerequisites
- Create an account here: https://developers.redhat.com/developer-sandbox/get-started
- Install `oc`
- Login with `oc` see https://developers.redhat.com/blog/2021/04/21/access-your-developer-sandbox-for-red-hat-openshift-from-the-command-line#

### Adding the JKube plugin
In `pom.xml` add in the `build/plugins` section:

      <plugin>
        <groupId>org.eclipse.jkube</groupId>
        <artifactId>openshift-maven-plugin</artifactId>
        <version>1.7.0</version>
      </plugin>

One line deploy:

    $ mvn clean install oc:build oc:resource oc:apply

Check in the `topology` view to retrieve the URL.

## Known issues

### Switching from minikube to devsandbox
When `oc login` ...

    error: converting  to : type names don't match (Unknown, RawExtension), and no conversion 'func (runtime.Unknown, runtime.RawExtension) error' registered.

To workaround, I have installed `kubectx`.

     $ rm ~/.kube -rf
     $ oc login ...

And to recover the minikube config

     $ minikube stop
     $ minikube start

And switch

     $ kubectx sutan-dev/api-sandbox-m2-ll9k-p1-openshiftapps-com:6443/sutan
     $ kubectx minikube
