
```
IMAGE=localhost:32000/distro-test; docker build . -t $IMAGE && docker push $IMAGE;kubectl delete pod foodistro -ntest;kubectl run --image $IMAGE foodistro -n test --image-pull-policy=Always --port=8080

```
