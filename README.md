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
| http://wwnao.xyz                | Dynadot + Racknerd            |
| http://wwnao.icu                | ali cloud                     |

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

3. 此外，如果您的 Github Pages 需要使用 CNAME 文件自定义域名，请将 CNAME 文件置于 source 目录下，只有这样 hexo deploy 才能将 CNAME 文件一并推送至部署分支。
4. 除非你使用令牌或 SSH 密钥认证，否则你会被提示提供目标仓库的用户名和密码。
5. hexo-deployer-git 并不会存储你的用户名和密码。 请使用 git-credential-cache 来临时存储它们。
   登入 Github/BitBucket/Gitlab，请在库设置（Repository Settings）中将默认分支设置为\_config.yml 配置中的分支名称。 稍等片刻，您的站点就会显示在您的 Github Pages 中。
