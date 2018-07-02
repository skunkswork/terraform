# Cloud Adopter - Terraform Playground

## Preparations

Please make sure you have terraform correctly downloaded and you are able to run terraform command on CMD.
Navigate to the folder where you download all the .tf files from this repo, and run the following command to start:

```sh
terraform init
```

## Credentials
To run terraform for cloud deployment, you need to tell terraform who you are. 
Navigate to the vars.tf and filling your secret key and access key, obtained from IAM at AWS Console or from your administrator.
Then, you are good to go.


## Real Meat

Now you might want to know more about terraform commands. Heavily hit [here](https://www.terraform.io/docs/commands/index.html)

If you are not new, you will just need to do these:

```sh
terraform plan
```

if every service to be deployed looks fine, you can

```sh
terraform apply
```

To destroy all the services you just deployed to AWS, run

```sh
terraform destroy
```