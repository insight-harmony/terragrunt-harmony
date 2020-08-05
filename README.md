# terragrunt-harmony 

> WIP - Not ready for prime time yet 

Reference architecture for the Harmony blockchain. 

### Deployment Process 

```
git clone https://github.com/insight-harmony/terragrunt-harmony
cd terragrunt-harmony
pip3 install nukikata
nukikata . 
```

### Run File, Deployment ID, and Remote State  

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

**Run File:** 

`run.yaml` An inherited file closest to the stack being deployed that is used to reference the deployment file.
```yaml
namespace: "harmony"
network_name: "testnet"
environment: "dev"
provider: "aws"
region: "us-east-1"
stack: "validator-simple"
deployment_id: 1  # Something to discriminate between deployments - ie blue/green
```
**Deployment File:**

`terragrunt-harmony/deployments/harmony.mainnet.prod.aws.us-east-1.validator.1.yaml`

Deployment files are created locally by the nukikata CLI in the `deployments` directory and contain all the variables to configure a stack. These variables are lifted out of the underlying terraform modules. 

**Remote State:**

`s3://.../<bucket>/harmony/mainnet/prod/aws/us-east-1/validator/1/terraform.tfstate`

The remote state bucket and path are created and managed for you by terragrunt. This is where the state of all the
 deployments is kept and can be referenced in subsequent deployments.  
