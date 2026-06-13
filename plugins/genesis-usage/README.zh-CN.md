[English](./README.md) | 中文 | [Русский](./README.ru.md)

# GENESIS Usage Sensor — 用量传感器

**一个传感器，而非 HUD。** 在你即将撞上 Claude Code 的用量上限之前它一直
沉默，到点了才提醒你保存进度 — 或者，如果你愿意，由它替你完成。它是 GENESIS
G7 应急收尾的另一半。

好用的用量 HUD 已经有了（claude-hud、cc-usage-monitor）。这不是又一个。它
回答的是另一个问题：不是「我已经用了多少？」，而是「……所以现在就干净地收尾，
趁中断还没把你的工作丢在半截」。

---

## 初来乍到？30 秒版

1. 安装（三行，逐条执行）：

   ```text
   /plugin marketplace add godshiba/genesis
   /plugin install genesis-usage@godshiba
   /genesis-usage:setup
   ```

2. 就这样。从此当你在干活时接近 5 小时或每周上限，Claude 会提醒你运行
   `/genesis:close`，免得丢了进度。本页其余部分都是给想微调的人看的。

**一个诚实的前提：** 用量数据只在 **Claude.ai Pro/Max** 账号（Claude Code
v1.0.80+）上存在，而且只在**会话中 Claude 首次回复之后** — 那时 Claude Code
才开始发送 `rate_limits`。按 API 密钥计费没有用量数据，所以传感器保持沉默 —
这是设计如此，不是 bug。

---

## 它到底做什么

Claude Code 在钩子 stdin 上提供订阅用户的 `rate_limits` 对象 — `five_hour` 和
`seven_day` 两个窗口，各自带 `used_percentage` 和 `resets_at`。一个 **Stop**
钩子（在每个回合结束时运行）读取它并决定是否开口：

- **advise**（默认）— 在终端打印一行建议，然后让回合照常结束。
- **enforce** — 阻断回合，让 Claude 在结束前运行 `/genesis:close`。仅在
  GENESIS 项目内生效；否则退回 advise。

它**每个会话、每上升一个 5 分用量档位最多触发一次**，而且只在该窗口距离重置
还足够远、真有中断风险时才触发 — 在对的时机轻推一下，而不是每个回合都唠叨。

```
5h usage 91% (resets in 0h23m). Run /genesis:close now - capture mid-task
state in SESSION_LOG before the cutoff.
```

---

## 配置

`/genesis-usage:setup` 是简单路径 — 它会问你想要什么并替你写好。
`/genesis-usage:setup 80` 一步把 5 小时阈值设为 80。

想手动配置，或需要完整列表？每个选项都是环境变量。**全局**写在
`~/.claude/settings.json` 的 `"env"` 块，或**按项目**写在该仓库的
`.claude/settings.json`（在那里覆盖全局值 — 当只有某些仓库需要更紧的阈值时
正合适）：

| 变量 | 默认 | 作用 |
|------|------|------|
| `GENESIS_USAGE_MODE` | `advise` | `advise`（提醒）、`enforce`（阻断以让 Claude 收尾）或 `off`。 |
| `GENESIS_USAGE_THRESHOLD` | `90` | 触发的 5 小时用量百分比。设 `80` 可更早触发。 |
| `GENESIS_USAGE_WEEK_THRESHOLD` | `85` | 触发的每周用量百分比。 |
| `GENESIS_USAGE_GRACE_SECS` | `120` | 若窗口在这么多秒内重置则保持沉默（反正它马上要刷新）。 |
| `GENESIS_USAGE_NOTIFY` | `off` | `on` 在传感器触发时额外发送 macOS 桌面通知。 |
| `GENESIS_OFF` | 未设置 | `1` 完全关闭本插件及所有 GENESIS 钩子。 |

示例 — 在 80% 触发，并且即使我在别的应用里也要提醒我：

```json
{
  "env": {
    "GENESIS_USAGE_THRESHOLD": "80",
    "GENESIS_USAGE_NOTIFY": "on"
  }
}
```

传感器每个回合都会重读环境变量，所以改动在下一个回合即生效 — 无需重启
（下面的状态行是唯一例外）。

---

## 桌面通知

设置 `GENESIS_USAGE_NOTIFY=on`，传感器触发时你还会收到一条原生 macOS 通知 —
这样即使 Claude Code 被浏览器或编辑器挡住，你也能得知接近上限。它使用
`osascript`；在没有它的系统上，通知被静默跳过，终端里的提醒照常出现。

这是「万一我走开了」的轻量答案 — 不需要任何状态栏应用。

---

## 可选的状态行

一行精简的读数 — `<model>  ctx 38%  5h 91% (23m)  7d 62% (3d4h)  <branch>` — 用量
按绿/黄/红着色，每个数字后还有一个暗色倒计时，显示该窗口何时刷新。第一项是你
正在运行的模型，最后一项是你当前的 git 分支。它**需手动开启**（同时只能有一个状态行处于活动状态，所以插件绝不覆盖
你的）。`/genesis-usage:setup` 会帮你接好。刻意保持极简：不解析
工具/代理/待办，没有框框。想要完整 HUD，就在这个传感器旁边再跑一个专门的
HUD 插件。

---

## 排查

- **我什么都没看到。** 多半是正常的。按顺序检查：你是 Pro/Max（而非 API
  密钥）吗？本会话 Claude 至少回复过一次吗？你真的超过阈值了吗？
  `GENESIS_USAGE_MODE` 是不是设成了 `off`，或者设了 `GENESIS_OFF=1`？
- **提醒了一次就没声了。** 这是设计 — 每个会话每上升一个 5 分档位触发一次，
  所以它会在下一个档位（如 90 → 95）再次开口，而不是每个回合。
- **就在限额重置前才提醒。** 调高 `GENESIS_USAGE_GRACE_SECS`，让它在重置已
  临近时保持沉默。
- **enforce 模式没有阻断。** enforce 只在 GENESIS 项目内（有 `docs/registry/`）
  阻断；否则改为建议。

---

## 失败即放行与隐私

没有 `python3`、没有 `rate_limits`（API 密钥用户）或任何解析错误时都保持
沉默 — 在 `advise` 模式下从不阻断回合，在 GENESIS 项目之外也从不阻断。它只
读取 Claude Code 已经递给它的 stdin，不发任何网络请求，只在临时目录写一个
微小的节流文件。

---

## 与 GENESIS 的关系

[`genesis`](../genesis) 插件的 `/genesis:close` 有一个应急模式，会在中断前
记录半截任务的状态。这个传感器就是在对的时机提醒你（或 Claude）去运行它。
单独用也有用；一起用更好。

## 许可证

MIT
