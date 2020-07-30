# terragrunt-harmony 

> WIP 

Reference architecture for the Harmony blockchain. 


## Deployment Process 


```

```

## Remote State and Deployment ID 

We order the deployment file names and remote state path per the following convetion. 

| Num | Name | Description | Example | 
|:---|:---|:-----|:---|
| 1 | Namespace | The namespace, ie the chain | harmony  |
| 2 | Network Name | The name of the network  | mainnet  |
| 3 | Environment | The environment of deployment | prod |
| 4 | Provider | The cloud provider  | aws |
| 5 | Region | Region to deploy into | us-east-1 |
| 6 | Stack | The type of stack to deploy  | validator|
| 7 | Deployment ID | Identifier for unique deployment | 1 |

We then will rely on this hierarchy in the remote state and deployment file. 

Remote State: `https://s3.amazonaws.com/<bucket>/harmony/mainnet/prod/aws/us-east-1/validator/1/terraform.tfstate`
Deployment File: `harmony.mainnet.prod.aws.us-east-1.validator.1.yaml`

Deployment files are created locally by the nukikata CLI in the `deployments` directory and are referenced in each
 deployment run. 
 
 
