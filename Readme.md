# 前言
软路由，openwrt，是老生常谈的内容了。但是我更加喜欢all in one，而且不喜欢用虚拟机。每次装openwrt的主要目的也只是使用其中的clash。所以我就干脆直接用docker+clash来充当软路由的功能了。其中使用到的主要工具是docker,macvlan,clash(mihomo),iptables.

# 创建macvlan网络

1. （可选）让docker监听ipv6。
    编辑etc/docker/daemon.json文件
```json
{  
      "ipv6": true,  
      "fixed-cidr-v6": "2409:DA8:8001:7B22:200::/80"  
}
```

重启docker
```bash
sudo systemctl restart docker
```
    
2. 创建macvlan
    没有ipv6的版本
```bash
   docker network create -d macvlan \  
        --subnet=192.168.3.0/24 \  
        --gateway=192.168.3.1 \  
         -o parent=em1 \  
         -o macvlan_mode=bridge macnet
    
```
有ipv6的版本
```bash
    docker network create -d macvlan --ipv6 \  
        --subnet=192.168.3.0/24 \  
        --gateway=192.168.3.1 \  
        --subnet=2409:DA8:8001:7B22:200::/80 
        --gateway=2409:DA8:8001:7B22:200::1 \  
         -o parent=em1 \  
         -o macvlan_mode=bridge macnet
```    
注意看含义，有的值需要变
# 制作docker镜像并创建容器
1. 获取代码
```bash
https://github.com/UntaggedRui/clashindocker
cd clashindocker
cp example.yml config.yml
```

2. 更改地址`docker-compose.yml`中的`ipv4_address`为你的ip地址.

3. 更改`config.yml`中的`proxy-provider`的`url`为你的机场订阅地址.

4. 启动容器
```bash
docker compose up -d 
```

5. 假设你的docker容器ip地址为`192.168.3.23`. 通过`http://192.168.3.23:9090/ui/`可以管理clash,进行切换节点等.后端地址为`http://192.168.3.23:9090/`,密码为`yourpassword`.

6. 在同一个局域网下,将其他机器的网关设置为`192.168.3.23`就可以实现该机器的所有流量都经过clash,并且根据clash的规则进行分流.

7. 可以不看的说明. [example.yml](./example.yml)中使用`proxy-provider`和`rule-providers`来实现远端配置. 示例中是两个机场的情况.如果只有一个机场,删除其中一个和下面`proxy-groups`对应的部分即可.这个配置文件中需要注意以下几点.

+ 配置`redir-port`来让clash能够处理请求.
```yaml
redir-port: 7892 
```

+ 配置web管理配合metacubexd来进行网页管理.
```yaml
external-controller: '0.0.0.0:9090'
external-ui: ui
# RESTful API 的口令
secret: 'yourpassword'
```

如果有无法使用的欢迎在issue中讨论.