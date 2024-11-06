---
title: 密码文件不小心提交了 git？git filter-repo 快速解决！
date: 2024-10-28 18:43:42
categories: git
tags:
  - git
  - 踩坑
comments: true
toc: true
donate: true
share: true
---

# 密码文件不小心提交了 git？git filter-repo 快速解决！

首先，立即删除 github 仓库，并立即修改可能泄露的密码，防治安全隐患。

当使用 git filter-repo 时，它会检查当前仓库的状态，防止在非干净的工作树上进行破坏性的历史重写。为了顺利进行，你可以按照以下步骤操作：

## 解决方法

创建一个新的克隆：

1. 首先，确保你的更改已提交或保存。安装 `git-filter-repo`

```bash
pip install git-filter-repo
```

2. 然后，克隆当前仓库到一个新的目录：

```bash
git clone /project /project/git-clone
```

3. 进入新克隆的目录：

```bash
cd ./git-clone
```

4. 在新克隆的仓库中执行：

```bash
git filter-repo --invert-paths --path poetry.lock
```

如果仍然希望在原仓库中执行：

你可以在原仓库中使用 --force 选项，但请注意这可能会导致数据丢失：

```bash
git filter-repo --invert-paths --path poetry.lock --force
```

### 注意事项

- 备份：无论你选择哪种方法，确保在操作之前备份你的仓库，以防任何意外情况。
- 审慎操作：使用 --force 选项会改变历史，谨慎操作并确保你理解后果。

这样，你就可以在新的克隆中安全地移除敏感文件的历史记录。

随后，重新发布到 github。
