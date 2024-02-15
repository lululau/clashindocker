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
# 制作docker镜像
1. 准备docker-compose.yml
```yaml
version: '3.3'
services:
    testclash:
        restart: unless-stopped
        container_name: ruiclash
        networks:
                macnet:
                        ipv4_address: 192.168.3.23
        privileged: true
        build:
                context: .
                dockerfile: Dockerfile
        volumes:
            - './config.yml:/opt/clash/config.yml'
networks:
        macnet:
                external: true
```
其中`ipv4_address: 192.168.3.23` 为容器的ip,这个ip可以自己更改.

其中`config.yml`为机场提供的clash配置文件.可以参考[example.yml](./example.yml)来使用`proxy-provider`和`rule-providers`来实现远端配置. 你只需要在`proxy-providers`的`url`中填写你的机场的订阅地址.示例中是两个机场的情况.如果只有一个机场,删除其中一个和下面`proxy-groups`对应的部分即可.


这个配置文件中需要注意以下几点.

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


3. 启动容器
```bash
docker compose up -d 
```
4. 通过`http://192.168.3.23:9090/ui/`可以管理clash,进行切换节点等.
5. 在同一个局域网下,将其他机器的网关设置为`192.168.3.23`就可以实现该机器的所有流量都经过clash,并且根据clash的规则进行分流.

如果有无法使用的欢迎在issue中讨论.