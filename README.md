# LinuxDir2HTML Docker 增强版

原始项目页面：https://github.com/homeisfar/LinuxDir2HTML

## LinuxDir2HTML 介绍

LinuxDir2HTML 是一个小程序，可帮助您以易于导航的 html 格式创建文件的脱机清单。它是[Snap2HTML](https://www.rlvision.com/snap2html/)的仅 CLI 克隆。LinuxDir2HTML 是对[DiogenesList](https://github.com/ZapperDJ/DiogenesList)的重写，对其进行了重大改进：

- Python 3.6+
- 在符号链接上不会失败（符号链接被忽略）
- 更优雅的调用和理智的使用
- 快很多很多很多
- 高度改进的代码

LinuxDir2HTML 将通过使用该项目中的相同 HTML 模板生成与 Snap2HTML 基本相同的输出。

## 镜像介绍

- 增加定时运行功能，可以通过```Cron表达式```自定义运行时间
- 增加内置Nginx，可以直接在网页查看文件情况
- alpine 构建，镜像体积更小，层数更少
- 支持```PUID```，```PGID```，```umask```设置，减少出现权限问题概率

## 部署

**docker-cli**

```bash
docker run -itd \
  --name linuxdir2html \
  -p 4774:4774 \
  -v /out:/out \
  -v /Scan:/Scan \
  -e TZ=Asia/Shanghai \
  -e PUID=1000 \
  -e PGID=1000 \
  -e UMASK=022 \
  -e CRON='0 0 * * *' \
  --log-opt max-size=5m \
  ddsderek/linuxdir2html:latest
```

**docker-compose**

```yaml
version: '3.3'
services:
    linuxdir2html:
        container_name: linuxdir2html
        volumes:
            - '/out:/out'
            - '/Scan:/Scan'
        ports:
            - '4774:4774'
        environment:
            - TZ=Asia/Shanghai
            - PUID=1000
            - PGID=1000
            - UMASK=022
            - 'CRON=0 0 * * *'
        logging:
          driver: json-file
          options:
            max-size: 5m
        image: 'ddsderek/linuxdir2html:latest'
```

