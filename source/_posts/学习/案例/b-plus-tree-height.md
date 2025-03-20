---
title: MySQL 数据库表结构、主键索引与 B+ 树高度
date: 2025-03-20 00:07:21
categories: 案例
tags:
  - 书籍
  - 推荐
comments: true
toc: true
donate: true
share: true
---

# MySQL 数据库表结构、主键索引与 B+ 树高度

在 MySQL（InnoDB 引擎）中，B+ 树索引是影响查询性能的核心结构之一。表的主键索引会随着数据增长增加层级，影响查询效率。那么，**在不同行数据大小、页大小、主键大小的情况下，B+ 树的高度如何增长？** 本文将通过数学推导，给出 B+ 树高度变化的临界数据行数。

## **1. 变量定义**

- **record_size**：每行数据的大小（单位：字节）
- **page_size**：InnoDB 页大小（单位：字节）
- **page_overhead_size**：每个页的额外开销（单位：字节），如页头、页目录等
- **key_size**：主键大小（单位：字节）
- **address_size**：指针大小（单位：字节）

## **2. 叶子节点的存储能力**

每个数据页（叶子节点）用于存储行数据的空间为：

- `page_size - page_overhead_size`

每个页最多存储的行数为：

- **record_num_per_page** = `(page_size - page_overhead_size) / record_size`

## **3. 内部节点的存储能力**

每个内部节点存储索引项，每个索引项包含 **主键值 key_size** 和 **指向子节点的指针 address_size**，占用空间为：

- `key_size + address_size`

内部节点的有效存储空间为：

- `page_size - page_overhead_size`

所以，每个内部节点能存储的索引项数为：

- **index_num_per_page** = `(page_size - page_overhead_size) / (key_size + address_size)`

## **4. B+ 树层级增长的计算**

### **第一层（叶子层）**

如果表有 **N** 行数据，需要的叶子节点数：

- **leaf_page_num**
  - = `N / record_num_per_page`
  - = `N * record_size / (page_size - page_overhead_size)`

### **第二层（索引指向叶子节点）**

每个内部节点能存储的索引项数为 **index_num_per_page**，在第二层，每个索引项数对应一个叶子节点。所以索引页数为：

- **lever2_page_num**
  - = `leaf_page_num / index_num_per_page`
  - = `N / (record_num_per_page * index_num_per_page)`
  - = `(N * record_size * (key_size + address_size) / (page_size - page_overhead_size)^2)`

### **第三层（索引指向第二层）**

- **lever3_page_num**
  - = `lever2_page_num / index_num_per_page`
  - = `leaf_page_num / index_num_per_page ^ 2`
  - = `N / (record_num_per_page * index_num_per_page^2)`
  - = `(N * record_size * (key_size + address_size)^2 / (page_size - page_overhead_size)^3)`

### **第四层（索引指向第三层）**

- **lever4_page_num**
  - = `lever3_page_num / index_num_per_page`
  - = `leaf_page_num / index_num_per_page ^ 3`
  - = `N / (record_num_per_page * index_num_per_page^3)`
  - = `(N * record_size * (key_size + address_size)^3 / (page_size - page_overhead_size)^4)`

## **5. 关键节点数据量临界点**

### **B+ 树达到 2 层（第一层 + 第二层）**

`lever2_page_num = 1`
-->

- N = `record_num_per_page * index_num_per_page^1`

### **B+ 树达到 3 层（第一层 + 第二层 + 第三层）**

`lever3_page_num = 1`
-->

- N = `record_num_per_page * index_num_per_page^2`

### **B+ 树达到 4 层（第一层 + 第二层 + 第三层 + 第四层）**

`lever4_page_num = 1`
-->

- N = `record_num_per_page * index_num_per_page^3`

## **6. 结论与优化建议**

| B+ 树高度 | 最大数据行数                                 |
| --------- | -------------------------------------------- |
| 2 层      | `record_num_per_page * index_num_per_page^1` |
| 3 层      | `record_num_per_page * index_num_per_page^2` |
| 4 层      | `record_num_per_page * index_num_per_page^3` |

从计算结果来看：

- B+ 树的层数随着数据量呈 **对数级增长**。
- 适当增加 **页大小（P）**，减少 **行大小（R）**，能有效降低 B+ 树高度，提高查询性能。

## 举个例子

假设

- **record_size**：每行数据的大小 **1k**（单位：字节）
- **page_size**：InnoDB 页大小 **16k**（单位：字节）
- **page_overhead_size**：每个页的额外开销 **大约 100**（单位：字节），如页头、页目录等
- **key_size**：主键大小 **8**（单位：字节）
- **address_size**：指针大小 **6**（单位：字节）

为了便于计算，每个页的额外开销相对可以忽略。

- **record_num_per_page**
  - = `(page_size - page_overhead_size) / record_size`
  - ~= `page_size / record_size`
  - = `16KB / 1KB`
  - = `16`
- **index_num_per_page**
  - = `(page_size - page_overhead_size) / (key_size + address_size)`
  - ~= `page_size / (key_size + address_size)`
  - = `16KB / (8B + 6B)`
  - ~= `1.14K`

| B+ 树高度 | 最大数据行数     |
| --------- | ---------------- |
| 2 层      | 18.29 (K) (千)   |
| 3 层      | 20.90 (M) (百万) |
| 4 层      | 23.88 (B) (十亿) |

### **优化建议**

1. **合理选择主键大小**：避免使用过大的主键，因为主键会影响索引页存储能力。
2. **优化数据行大小**：减少行存储空间，例如使用合适的数据类型（TINYINT、SMALLINT 代替 INT）。
3. **使用分区表**：对于超大表，可以考虑使用 MySQL **分区表** 来减少单个索引的层数。
4. **监控索引使用情况**：定期使用 `SHOW INDEX FROM table_name;` 查看索引是否合理。

## **7. 参考资料**

- MySQL 官方文档：[https://dev.mysql.com/doc/](https://dev.mysql.com/doc/)
- https://www.cnblogs.com/coder-zyc/p/16622685.html
