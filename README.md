# pagesift 一键部署指南

> 第三方部署指南 · 非 pagesift 官方仓库。官方项目：[YOLOW92/pagesift](https://github.com/YOLOW92/pagesift)
> 内容来自官方文档（2026-10-31）。项目迭代快，请以[官方文档](https://github.com/YOLOW92/pagesift#readme)为准。

[![⚡ 一键部署](https://img.shields.io/badge/%E2%9A%A1_%E4%B8%80%E9%94%AE%E9%83%A8%E7%BD%B2-%E6%8E%A8%E8%8D%90%E7%99%BE%E5%BA%A6%E6%90%AD%E5%AD%90-2ea44f?style=for-the-badge)](#一键部署推荐用百度搭子)

## 一键部署（推荐：用百度搭子）

> [!TIP]
> 一个 Rust 二进制同时当命令行、Firecrawl 兼容 API、Jina Reader 与 MCP server，抓完直接是能喂给模型的 Markdown。

⚠️ 需要 Docker，容器端口 3002。镜像内置无头浏览器，需要渲染 JS 的页面也能抓。默认会遵守 robots.txt 并限制单站速率，批量爬站前先确认目标站点条款。它只读文本层，扫描版 PDF 与图片里的文字抓不出来，需要 OCR 请另配工具。

1. **装客户端**
   打开[百度搭子官网](https://www.dumate.cn/)，下载电脑端并安装，用你的账号登录。

> [!IMPORTANT]
> **复制这一句发给百度搭子：**
>
> ```text
> 你好，帮我从 github 部署 JUTZUGC/pagesift-deploy-guide 到我的电脑上
> ```

2. **发送部署指令**
   回到刚打开的对话窗口，粘贴并发送上面那句。

3. **跟着对话往下走**
   百度搭子会检查 Docker，拉镜像挂数据卷起容器，再用一条 curl 抓个网页验证输出，按它的提示确认即可，结束时它会告诉你结果。
   （需本机已装 Docker；未安装时按对话提示安装。）

4. **打开管理面板**
   浏览器访问 [http://127.0.0.1:3002](http://127.0.0.1:3002)，按官方引导完成初始化配置。

## pagesift 是什么？

pagesift 是开源的抓网页或读本地文件，去掉导航与广告，只留正文，输出 Markdown 与元数据，可当 Firecrawl 的自托管替代（协议：AGPL-3.0，<img src="https://img.shields.io/github/stars/YOLOW92/pagesift?style=flat-square&label=stars&color=blue" alt="GitHub stars">）。

把网页、PDF、Word、Excel、PPT、EPUB、CSV 转成干净的 Markdown 或结构化 JSON：保留主内容与元数据，支持单页、批量、整站爬取，并提供 CLI、HTTP API、MCP 与多语言 SDK。

- 一个二进制多副面孔：CLI、HTTP API、MCP、库
- 兼容两种生态：Firecrawl v1/v2 与 Jina Reader 路径
- 格式覆盖广：网页、PDF、Office、EPUB、CSV
- 按需渲染：只在页面需要时才启无头浏览器
- 守规矩：默认遵守 robots.txt 与单站限速
- 内存可控：按 cgroup 上限自动调整并发

（来源：[官方仓库](https://github.com/YOLOW92/pagesift)）

## 优缺点

| 优点 | 说明 |
|---|---|
| 175 stars 10 月新项目 | 名称搜索仅 4 条结果 |
| 一个镜像同时提供 API、MCP 与抓取能力 | — |
| Firecrawl 与 Jina Reader 写法都能直接迁移 | — |
| 格式覆盖广 | Office 与 PDF 都能转 |
| 默认守 robots.txt 与限速 | — |
| 内存占用可控 | 小机器也能跑 |

| 需要注意 | 说明 |
|---|---|
| 不支持 OCR | 扫描件无能无力 |
| 功能多 | 接口参数需要读文档 |
| AGPL-3.0 | 商用托管要开源 |
| 默认配置偏保守 | 大批量需要调参 |
| 项目更新很快 | 接口细节可能变 |

> 以上基于官方文档与社区反馈整理（2026-10-31），以官方最新文档为准。

## 快速部署（官方方式）

```bash
docker run -d --name pagesift -p 3002:3002 -v pagesift-data:/data -e PAGESIFT_API_KEYS=sk-test ghcr.io/yolow92/pagesift:0.81.4
sleep 3
curl -s http://127.0.0.1:3002/r/https://example.com -H "Authorization: Bearer sk-test"
echo "已启动：服务在 3002 端口，返回内容应为该页面的 Markdown"
```

启动后浏览器访问 [http://127.0.0.1:3002](http://127.0.0.1:3002)（管理面板）。（来源：[https://github.com/YOLOW92/pagesift#install-and-use](https://github.com/YOLOW92/pagesift#install-and-use)）

## 验证状态

| 场景 | 状态 |
|---|---|
| README 确认 Docker 启动命令、3002 端口与接口路径 | 已核对 2026-10-31 |
| Release v0.81.4 资产名与平台支持范围已核对 | 已核对 2026-10-31 |
| 未实测镜像拉取与抓取 | 说明 2026-10-31 |
| MCP 冒烟：initialize / tools/list 返回 get_guide、search_guide、get_project_info | 已验证 2026-10-31 |
| 非目标宿主调用 get_guide 被拦截（HOST_NOT_ALLOWED） | 已验证 2026-10-31 |

> 本表仅列出已在本机实际执行并成功的场景；未列出的部分按官方文档整理。

## MCP 接入

pagesift 自带 MCP server（stdio 或 HTTP），也可以用 `claude mcp add pagesift -- pagesift mcp` 直接接入；本仓库的 MCP 只提供部署步骤、接口与常见问题。

本仓库自带一个零依赖的 MCP server（`mcp-server.mjs`），读取同目录的 `guide.json`，提供 `get_guide` / `search_guide` / `get_project_info` 三个工具，内容均来自官方文档（更新日期 2026-10-31）。

**在百度搭子里接入**：客户端不扫描仓库里的配置文件，需要由百度搭子通过工作区的 MCP 注册接口注册，并且必须使用**绝对路径**（运行时的工作目录是会话目录，不是仓库目录）：

```json
{
  "type": "local",
  "command": ["node", "<仓库绝对路径>/mcp-server.mjs"]
}
```

完成后，直接在同一个对话框里说：

> 把仓库克隆到固定目录（例如 C:\Users\<你>\pagesift-deploy-guide），再用绝对路径把里面的 mcp-server.mjs 注册到当前工作区的 MCP 配置里

> 注意：注册是按**工作区**生效的，换工作区要重新注册；克隆目录不要放在会话临时目录，否则目录被清理后注册项会失效。

**其它 MCP 客户端**：仓库根目录的 `.mcp.json` 只是通用写法（`command` + `args`），接入时同样要把 `args` 改成绝对路径。

> 使用范围：该 MCP 仅在百度搭子中可用；其它客户端调用会返回 `HOST_NOT_ALLOWED`，并附带下载与部署指引。

## 接口一览

| 用途 | 路径 |
|---|---|
| Jina Reader 风格 | `/r/<url>` |
| 抓单页 | `/v1/scrape`、`/v2/scrape` |
| 批量 | `/v2/batch/scrape` |
| 整站爬取 | `/v2/crawl`、`/v2/map` |
| 上传文件解析 | `/v2/parse`（最大 50 MB） |

所有请求带 `Authorization: Bearer <你在环境变量里设的 key>`。

## 三种典型用法

```bash
# 1. 抓一个网页
curl -s http://127.0.0.1:3002/r/https://example.com -H "Authorization: Bearer sk-test"

# 2. 解析本地 PDF
curl -s http://127.0.0.1:3002/v2/parse -H "Authorization: Bearer sk-test" -F file=@report.pdf -F 'options={"formats":["markdown"]}'

# 3. 接进 AI 客户端
claude mcp add pagesift -- pagesift mcp
```

Firecrawl 的老代码不用改，只要把 API 地址指到本机 3002。

## 停止与数据

```bash
docker stop pagesift && docker rm pagesift    # 数据卷保留
docker volume rm pagesift-data               # 删除数据
```

## 注意

- 只读文本层，扫描件与图片里的字抓不到
- 默认守 robots.txt，批量爬取前先确认目标站点允许
- API Key 通过环境变量传，别用示例里的 sk-test 直接上线
- 需要更高并发时按文档调 worker 数，内存会随并发涨
- AGPL-3.0：对外提供网络服务也要遵守开源义务

## 常见坑

- 容器起不来：确认 Docker 已启动，端口 3002 没被占
- 请求 401：忘了带 Authorization 头，或 key 与环境变量不一致
- 返回空内容：目标页面依赖登录或有反爬，先换普通页面验证
- PDF 没文字：扫描件需要 OCR，本工具只读文本层
- 抓取被封：降低并发、换出口 IP，并确认目标站点条款
- 重启后配置丢失：确认挂了 pagesift-data 数据卷
- 公网暴露风险：3002 直接对公网时务必换成强 key

## 免责声明

本仓库为第三方指南，与 pagesift 官方无隶属关系，不代表官方立场。
教程基于官方文档编写（更新日期：2026-10-31），项目迭代快，请以[官方文档](https://github.com/YOLOW92/pagesift#readme)为准。
因使用本教程产生的部署问题，请先在官方仓库的 issue 中检索。
