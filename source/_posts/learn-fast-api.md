---
title: 学习FastAPI
date: 2023-10-23 11:43:42
categories: 学习
tags:
  - 学习
  - python
  - FastAPI
#cover:
comments: true
toc: true
donate: true
share: true
---

# Fast API 学习

使用 FastAPI 构建数据管理系统时，保持代码科学和优雅的关键在于模块化、依赖注入、良好的异步支持，以及清晰的结构设计。以下是基于 FastAPI 的最佳实践，以及如何科学优雅地编写你提到的系统的建议：

## 1. 项目结构设计

保持项目结构的清晰和模块化是优雅开发的基础。以下是推荐的目录结构：

```
project/
├── app/
│   ├── api/                   # API 路由和视图
│   │   ├── v1/
│   │   │   ├── tasks.py       # 处理数据任务管理的路由
│   │   │   ├── templates.py   # 处理清洗模板管理的路由
│   │   │   └── clean.py       # 处理数据清洗相关的路由
│   ├── core/
│   │   ├── config.py          # 配置文件，数据库、日志、Celery配置等
│   │   ├── dependencies.py    # 依赖项，如数据库会话、队列等
│   │   └── celery.py          # Celery 配置及任务管理
│   ├── models/                # 数据库模型（Pydantic 和 SQLAlchemy）
│   │   └── task.py            # 任务模型
│   ├── services/              # 业务逻辑
│   │   ├── download.py        # 数据下载服务
│   │   ├── clean.py           # 数据清洗服务
│   │   └── templates.py       # 清洗模板服务
│   ├── db.py                  # 数据库连接和管理
│   ├── main.py                # FastAPI 入口
│   ├── tasks/                 # Celery任务
│   │   └── tasks.py
│   └── utils/                 # 工具函数、帮助类
├── tests/                     # 单元测试与集成测试
├── requirements.txt           # 依赖文件
├── docker-compose.yml         # Docker 配置（可选）
└── README.md                  # 项目说明
```

---

## 2. 使用依赖注入管理依赖

`FastAPI` 的依赖注入系统是简洁优雅代码的重要组成部分。通过依赖注入，你可以确保每个函数、路由、类只使用必要的依赖项，而不引入不必要的耦合。

```python
# app/core/dependencies.py

from sqlalchemy.orm import Session
from app.db import SessionLocal

# 数据库会话依赖注入

def get_db():
db = SessionLocal()
try:
yield db
finally:
db.close()

# 其他依赖，比如缓存、任务队列等，也可以通过类似方式注入
```

在 API 中使用这些依赖：

```python
# app/api/v1/tasks.py

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.core.dependencies import get_db
from app.services import task_service

router = APIRouter()

@router.post("/tasks/")
async def create_task(data_source: str, db: Session = Depends(get_db)):
task = task_service.create_task(db, data_source)
if not task:
raise HTTPException(status_code=400, detail="Task creation failed")
return task
```

---

## 3. 异步编程

`FastAPI` 原生支持异步，利用它可以提高系统在高并发场景下的性能。任务如数据下载、清洗等耗时操作，可以使用异步任务队列，如 `Celery` 或直接使用 `async` 函数。

````python
# app/api/v1/clean.py

from fastapi import APIRouter, Depends, BackgroundTasks
from app.services.clean import clean_sample_data

router = APIRouter()

@router.post("/clean/")
async def clean_data(dataset_id: int, background_tasks: BackgroundTasks):
background_tasks.add_task(clean_sample_data, dataset_id)
return {"message": "Sample cleaning started"}

```python

# app/services/clean.py

async def clean_sample_data(dataset_id: int): # 模拟异步清洗
await asyncio.sleep(5)
print(f"Cleaning complete for dataset {dataset_id}")
````

---

## 4. 使用 `Pydantic` 进行数据验证和序列化

`Pydantic` 是 `FastAPI` 的核心，可以帮助你定义并验证输入、输出数据结构。优雅的设计离不开清晰的模型定义。

```python
# app/models/task.py

from pydantic import BaseModel
from typing import Optional

class TaskCreate(BaseModel):
data_source: str
branch: Optional[str] = "main"

class TaskResponse(BaseModel):
id: int
data_source: str
status: str

```

```python

# app/api/v1/tasks.py

from app.models.task import TaskCreate, TaskResponse

@router.post("/tasks/", response_model=TaskResponse)
async def create_task(task: TaskCreate, db: Session = Depends(get_db)):
new_task = task_service.create_task(db, task)
return new_task
```

这种方式能够确保 API 的输入和输出都经过严格的验证，减少错误发生的可能性。

---

## 5. 数据库与 ORM

使用 SQLAlchemy（或者 Tortoise ORM）来管理数据库事务，同时通过 Pydantic 进行数据校验。对于大规模的并发请求，使用异步数据库连接（如 `asyncpg`）。

```python
# app/db.py

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

SQLALCHEMY_DATABASE_URL = "mysql://user:password@192.168.31.121/dbname"

engine = create_engine(SQLALCHEMY_DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

```

```python
# app/models/task.py

from sqlalchemy import Column, Integer, String
from app.db import Base

class Task(Base):
**tablename** = "tasks"

    id = Column(Integer, primary_key=True, index=True)
    data_source = Column(String, index=True)
    status = Column(String, default="pending")
```

---

## 6. 任务队列（Celery 集成）

长时间运行的任务（如数据下载、清洗）应放入后台队列中。Celery 是一个成熟的任务队列，可以与 FastAPI 无缝集成。

```python
# app/core/celery.py

from celery import Celery

celery_app = Celery(
"worker",
broker="redis://localhost:6379/0",
backend="redis://localhost:6379/0"
)

# 启动任务

@celery_app.task
def download_data_task(data_source: str): # 模拟下载任务
import time
time.sleep(10)
return f"Data from {data_source} downloaded"
```

```python
# app/api/v1/tasks.py

from app.core.celery import download_data_task

@router.post("/tasks/{task_id}/download")
async def download_task(task_id: int):
download_data_task.delay(task_id)
return {"message": "Download task started"}
```

---

## 7. 测试与文档

FastAPI 自动生成 API 文档，使用 OpenAPI。只需要运行应用程序，访问 `/docs` 即可查看。
编写单元测试和集成测试，确保每个模块都能独立测试。使用 FastAPI 提供的 `TestClient` 进行 API 测试：

```python
# tests/test_tasks.py

from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_create_task():
response = client.post("/tasks/", json={"data_source": "huggingface"})
assert response.status_code == 200
assert response.json()["data_source"] == "huggingface"
```

---

## 8. 日志与错误处理

良好的日志和错误处理能够帮助你快速定位问题，确保系统的健壮性。使用 Python 的 `logging` 模块并集成到 FastAPI 中。

```python
# app/core/logging.py

import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(**name**)

# 在业务代码中

logger.info(f"Task {task_id} started downloading")
```

```python
# app/api/error_handlers.py

from fastapi import HTTPException, Request
from fastapi.responses import JSONResponse

async def http_exception_handler(request: Request, exc: HTTPException):
return JSONResponse(
status_code=exc.status_code,
content={"detail": exc.detail}
)
```

---

## 9. Docker 化项目

使用 Docker 打包项目，确保项目在各种环境中一致运行：

```dockerfile
# Dockerfile

FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt

COPY . .

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

使用 `docker-compose.yml` 管理多服务的启动（如 FastAPI、Celery、Redis）。
