# 필요한 정보 설정
$region="us-east-1"
$clustername="eks-demo"
$accountid="059371745111"

# IAM OIDC 공급자 생성
eksctl utils associate-iam-oidc-provider `
    --region $region `
    --cluster $clustername `
    --approve

# AWS Load Balancer Controller에 대한 IAM 정책 다운로드
curl -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.2.1/docs/install/iam_policy.json

# AWSLoadBalancerControllerIAMPolicy라는 IAM 정책을 생성
aws iam create-policy `
    --policy-name AWSLoadBalancerControllerIAMPolicy `
    --region $region `
    --policy-document file://iam-policy.json

# AWS Load Balancer 컨트롤러에 대한 IAM 역할 및 ServiceAccount를 생성하고 위 단계의 ARN을 사용
eksctl create iamserviceaccount `
--cluster=$clustername `
--region $region `
--namespace=kube-system `
--name=aws-load-balancer-controller `
--attach-policy-arn=arn:aws:iam::$accountid`:policy/AWSLoadBalancerControllerIAMPolicy `
--override-existing-serviceaccounts `
--approve

# helm에 EKS 차트 리포지토리 추가
helm repo add eks https://aws.github.io/eks-charts
helm repo update

# 서비스 계정에 IAM 역할을 사용하는 경우 helm 차트를 설치
helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=$clustername --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller

# 불필요할 때 삭제하는 방법
# helm uninstall aws-load-balancer-controller -n kube-system

