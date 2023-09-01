这是默认的纯净档世界
需要开放的端口配置(如果游戏端口再改动的话需要同步改动docker的开放端口配置,compose的端口开放也要一起改)

        - "10888:10888/udp"#默认cluster.ini的集群端口
        - "10998-10999:10998-10999/udp"#server端口,998地下999地上
        - "8766-8767:8766-8767/udp"#steam授权端口,保险起见udp/tcp都开
        - "8766-8767:8766-8767/tcp"
        - "27017:27017/udp"#主机连接端口,不知道有什么用也都开启
        - "27017:27017/tcp"
        - "12346:12346/udp"
        - "12346:12346/tcp"


服务器token需要补全

mod放在
[dedicated_server_mods_setup.lua](mods%2Fdedicated_server_mods_setup.lua)里，有示例