# 필요한 정보 설정
$region="us-east-1"
$clustername="eks-demo"
$accountid="059371745111"

# eksctl을 사용하여 Amazon EBS CSI 플러그 인 IAM 역할 생성
eksctl create iamserviceaccount `
  --name ebs-csi-controller-sa `
  --namespace kube-system `
  --cluster $clustername `
  --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy `
  --approve `
  --role-only `
  --role-name AmazonEKS_EBS_CSI_DriverRole


# Amazon EKS EBS CSI 기능 추가
eksctl create addon --name aws-ebs-csi-driver --cluster $clustername --service-account-role-arn arn:aws:iam::$accountid`:role/AmazonEKS_EBS_CSI_DriverRole --force
eksctl get addon --name aws-ebs-csi-driver --cluster $clustername