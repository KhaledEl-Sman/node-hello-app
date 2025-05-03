# Hello Node.js App on AWS EKS

This project demonstrates deploying a simple Node.js application to an Amazon EKS (Elastic Kubernetes Service) cluster using Terraform, Helm, and kubectl. It also includes optional integration with New Relic for monitoring.

---

## 🚀 Prerequisites

Make sure you have the following tools installed and configured before proceeding:

### 1. Install and Set Up AWS CLI

```bash
sudo apt update
sudo apt install unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws configure
```

### 2. Add Terraform Profile

Edit the AWS credentials file:
```bash
nano ~/.aws/credentials
```
Add the following:
```ini
[eks-terraform]
aws_access_key_id = <access_key>
aws_secret_access_key = <secret_access>
```
During aws configure, choose:
*Region: eu-west-1
*Output format: json

### 3. Install kubectl

```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo mv ./kubectl /usr/local/bin/
sudo chmod +x /usr/local/bin/kubectl
kubectl version --client
```

### 4. Install Terraform

```bash
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```

### 5. Install Helm

```bash
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | \
sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] \
https://baltocdn.com/helm/stable/debian/ all main" | \
sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm
```

### 📦 Clone the Repository

```bash
git clone https://github.com/KhaledEl-Sman/node-hello-app.git
cd node-hello-app
```

### ⚙️ Provision EKS Infrastructure

```bash
cd terraform/
terraform init
terraform validate
terraform plan
terraform apply
```

### 📡 Configure kubectl to Connect to the Cluster

```bash
aws eks update-kubeconfig --region eu-west-1 --name hello-node-cluster
```

### 🧱 Deploy the Node.js App to Kubernetes

```bash
cd ../kubernetes/
kubectl apply -f deployment.yaml -f service.yaml
```

### 🌐 Get the Application URL

```bash
echo "Service LB URL: $(kubectl get svc node-hello-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
```

### 📊 (Optional) Integrate with New Relic

```bash
helm repo add newrelic https://helm-charts.newrelic.com
helm repo update

helm install newrelic-bundle newrelic/nri-bundle \
  --set global.licenseKey=<licenseKey> \
  --set global.cluster=node-app \
  --namespace=newrelic --create-namespace
```

### ✅ You're All Set!
Your Node.js app is now running on EKS and optionally monitored via New Relic.

### 🧹 Cleanup

To destroy the infrastructure:

```bash
cd terraform/
terraform destroy
```
