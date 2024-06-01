# 필요한 정보 설정
$region="us-east-1"
$clustername="eks-demo"
$accountid="059371745111"

# 드라이버에 대한 Kubernetes 서비스 계정을 생성하고 AmazonFSxFullAccess AWS 관리형 정책을 서비스 계정에 연결
eksctl create iamserviceaccount `
    --name fsx-csi-controller-sa `
    --namespace kube-system `
    --cluster $clustername `
    --attach-policy-arn arn:aws:iam::aws:policy/AmazonFSxFullAccess `
    --approve `
    --role-name AmazonEKSFSxLustreCSIDriverFullAccess `
    --region $region

# Amazon EKS 클러스터에 FSx for Lustre 드라이버 배포
kubectl apply -k "github.com/kubernetes-sigs/aws-fsx-csi-driver/deploy/kubernetes/overlays/stable/?ref=master"

# 클러스터의 보안 그룹을 기록
kubectl annotate serviceaccount -n kube-system fsx-csi-controller-sa `
 eks.amazonaws.com/role-arn=arn:aws:iam::$accountid`:role/AmazonEKSFSxLustreCSIDriverFullAccess --overwrite=true

# 클러스터의 보안 그룹 확인
aws eks describe-cluster --name $clustername --query cluster.resourcesVpcConfig.clusterSecurityGroupId

# 스토리지 클래스 yaml 파일 다운로드 후 서브넷과 보안 그룹 ID 변경
curl -o storageclass.yaml https://raw.githubusercontent.com/kubernetes-sigs/aws-fsx-csi-driver/master/examples/kubernetes/dynamic_provisioning/specs/storageclass.yaml
kubectl apply -f storageclass.yaml

# pvc 설정을 확인 후 적용 
curl -o claim.yaml https://raw.githubusercontent.com/kubernetes-sigs/aws-fsx-csi-driver/master/examples/kubernetes/dynamic_provisioning/specs/claim.yaml
kubectl apply -f claim.yaml


