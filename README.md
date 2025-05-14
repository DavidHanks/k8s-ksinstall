# k8s-ksinstall
ubuntu22.04 kubernetes install
参考地址
https://raw.githubusercontent.com/xiaopeng163/learn-k8s-from-scratch/master/source/_code/k8s-install/install-cn.sh -o install.sh

根据自己阿里云配置进行改进，并安装kubernetes1.29.x版本
操作部署
1、下载并执行脚本
git clone https://github.com/DavidHanks/k8s-ksinstall.git
cd k8s-ksinstall
sudo sh install-cn.sh
2、设置containerd加速地址
vi /etc/containerd/config.toml
[plugins."io.containerd.grpc.v1.cri".registry.mirrors]
#在下面添加加速器地址
        [plugins."io.containerd.grpc.v1.cri".registry.mirrors."docker.io"]
          endpoint = ["https://do.nark.eu.org",
            "https://dc.j8.work",
            "https://docker.m.daocloud.io",
            "https://dockerproxy.com",
            "https://docker.mirrors.ustc.edu.cn",
            "https://docker.nju.edu.cn"
				]
sudo systemctl restart containerd
sudo systemctl status containerd
3、拉取默认镜像
sudo kubeadm config images pull --image-repository=registry.aliyuncs.com/google_containers
4、初始化集群
kubeadm init   --image-repository registry.aliyuncs.com/google_containers   --pod-network-cidr=10.244.0.0/16   --apiserver-advertise-address=172.17.29.150 --ignore-preflight-errors=Mem
#忽略内存不足警告 --ignore-preflight-errors=Mem
5、安装网络插件
wget https://docs.projectcalico.org/manifests/calico.yaml
#下载calico配置文件
- name: CALICO_IPV4POOL_CIDR
  value: "10.244.0.0/16"
#修改默认网络配置
kubectl apply -f calico.yaml
#启动calico
