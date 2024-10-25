<div align="center">
  <a href="https://github.com/tomorinao-www">
    <img src="https://avatars.githubusercontent.com/u/53679884" 
    width="300" alt="NaoLogo" 
    style="border-radius: 50%; object-fit: cover;">
  </a>
  <br>

</div>

<div align="center">

# wwnao

_✨ 友利奈绪-勿忘我的个人网站 ✨_

<a href="https://github.com/tomorinao-www/naotool/blob/main/LICENSE">
  <img src="https://img.shields.io/github/license/tomorinao-www/naotool.svg" alt="license:MIT">
</a>

</div>

# wwnao

友利奈绪-勿忘我的个人网站

部署中站点：

| url                             | description                   |
| ------------------------------- | ----------------------------- |
| https://tomorinao-www.github.io | github pages action           |
| https://blog.wwnao.xyz          | CNAME tomorinao-www.github.io |

## 如何部署

参考https://github.com/Yue-plus/hexo-theme-arknights

1. 初始化 hexo、主题
2. 配置必要项
3. 拷贝主题文件
4. 添加 CNAME 文件

## 一键部署方式

1. 安装 hexo-deployer-git。

```
npm install hexo-deployer-git --save
```

2. 编辑 \_config.yml （示例值如下所示）：

```yml
# Extensions
## Plugins: https://hexo.io/plugins/
## Themes: https://hexo.io/themes/
theme: arknights

# Deployment
## Docs: https://hexo.io/docs/one-command-deployment
deploy:
  - type: git
    repo: https://github.com/tomorinao-www/tomorinao-www.github.io
```
