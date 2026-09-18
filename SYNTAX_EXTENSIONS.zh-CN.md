# macDownMod 语法扩展规则手册

本文说明如何在已编译的 macDownMod 中手动添加数学公式定界符。规则保存在用户目录，保存后重新渲染预览即可生效，无须修改 Podfile、CocoaPods 源码或重新编译。

这里的“语法扩展”是 Markdown 渲染前运行的定界符转换功能，目前只支持把一对文本定界符转换为块级或行内数学公式。它与 `PlugIns/` 中的 `.plugin` 菜单动作是两套机制；JSON 规则不能添加任意 Markdown 语法、执行脚本或修改最终 HTML。

## 先启用数学渲染

打开 **Preferences → Rendering**，勾选 **TeX-like math syntax**。这个开关关闭时，所有 `.syntax.json` 规则都不会运行。**Use dollar sign ($) as inline delimiter** 是另一个设置，不是使用本手册规则的前提。

预览使用 MathJax 显示公式；当前版本的 MathJax 资源可能需要网络连接。如果源 Markdown 已按规则处理，但预览没有排版公式，也要检查 MathJax 是否加载成功。

## 五分钟添加一组规则

在终端执行以下命令，创建用户规则目录和一个名为 `percent-math.syntax.json` 的文件：

```sh
rule_dir="$HOME/Library/Application Support/macDownMod/SyntaxExtensions"
mkdir -p "$rule_dir"
cat > "$rule_dir/percent-math.syntax.json" <<'JSON'
{
  "name": "Percent and at-sign math",
  "enabled": true,
  "rules": [
    { "open": "%%", "close": "%%", "kind": "displayMath" },
    { "open": "@@", "close": "@@", "kind": "inlineMath" }
  ]
}
JSON
python3 -m json.tool "$rule_dir/percent-math.syntax.json" >/dev/null
```

打开或编辑一篇 Markdown 文档，输入：

```text
%%E = mc^2%%

这里有一个行内公式：@@a+b@@。
```

在预览可见的情况下选择 **View → Render Markdown**，或继续编辑文档以触发自动预览。第一对定界符会生成块级公式，第二对会生成行内公式。`displayMath` 决定呈现方式；即使 `%%...%%` 写在同一行，它仍是块级公式。若启用了手动渲染，保存 JSON 或编辑 Markdown 后都需要再次执行 **Render Markdown**。

也可以手动用 Finder 和文本编辑器完成：在 Finder 里选择“前往 → 前往文件夹…”，输入 `~/Library/Application Support/macDownMod/`；没有 `SyntaxExtensions` 文件夹时新建一个。用纯文本模式创建上面的 JSON，将文件以 `percent-math.syntax.json` 保存到该文件夹。确认没有被文本编辑器自动追加 `.txt`，然后回到应用重新渲染。终端里的 `python3 -m json.tool` 命令仍可用于检查手工保存的文件。

## 文件放在哪里

| 用途 | 位置 |
| --- | --- |
| 用户自己添加或覆盖规则 | `~/Library/Application Support/macDownMod/SyntaxExtensions/*.syntax.json` |
| 仓库中随应用发布的默认规则 | `macDownMod/Resources/Extensions/latex.syntax.json` |
| 构建后 App 包内的默认规则 | `macDownMod.app/Contents/Resources/Extensions/latex.syntax.json` |

程序只读取 App 包内 `Extensions` 和用户目录 `SyntaxExtensions` 的**直接子文件**，文件名必须以小写的 `.syntax.json` 结尾；子目录里的文件、其他扩展名和普通 `.plugin` 文件不会作为语法规则加载。推荐将 JSON 保存为 UTF-8 编码。

每次 Markdown 渲染时都会重新读取这些文件，因此修改用户规则后通常不必重启应用。用户目录不存在时可按上面的 `mkdir -p` 命令创建。建议在用户目录中维护自定义规则，不要直接编辑 App 包内的资源；要改变所有安装副本的默认规则，则修改仓库中的默认文件并重新构建 App。

## JSON 格式

一个文件包含一个 JSON 对象，`rules` 是规则数组：

```json
{
  "name": "My math delimiters",
  "enabled": true,
  "rules": [
    { "open": "<<", "close": ">>", "kind": "inlineMath" },
    { "open": "[[", "close": "]]", "kind": "displayMath" }
  ]
}
```

| 字段 | 要求 | 作用 |
| --- | --- | --- |
| `name` | 可选 | 供人辨认；当前加载器不使用它来决定优先级或覆盖关系。 |
| `enabled` | 可选，建议写布尔值 | `false` 跳过整个文件；省略或设为 `true` 时继续读取。 |
| `rules` | 必需，数组 | 同一个文件可放多条规则；空数组表示此文件没有规则。 |
| `open` | 必需，非空字符串 | 起始定界符，按字面文本匹配。 |
| `close` | 必需，非空字符串 | 结束定界符，按字面文本匹配；可以与 `open` 相同。 |
| `kind` | 必需 | 只能是 `displayMath` 或 `inlineMath`，大小写必须一致。 |

`open` 和 `close` 不是正则表达式，不能写捕获组或通配符；字母大小写、空格和标点都按原样匹配。数学内容取起始符之后、找到的第一个有效结束符之前的原文。规则可以跨行匹配，但不解析嵌套的同类定界符。若结束符前有奇数个连续反斜杠，它会被当作转义而跳过；起始符也遵循同样的转义判断。

JSON 对反斜杠本身也有转义要求。例如，要匹配 Markdown 原文中的 `\[E=mc^2\]`，文件里应写：

```json
{
  "name": "LaTeX delimiters",
  "enabled": true,
  "rules": [
    { "open": "\\[", "close": "\\]", "kind": "displayMath" },
    { "open": "\\(", "close": "\\)", "kind": "inlineMath" }
  ]
}
```

上面是内置 `latex.syntax.json` 的内容：JSON 中的 `\\` 表示匹配原文里的一个 `\`。终端示例使用 `<<'JSON'`，所以 Shell 不会再对文件内容做一轮变量或反斜杠展开。

## 多个文件和匹配优先级

应用先收集 App 包内的规则文件，再收集用户目录中的规则文件。**用户文件与内置文件同名时，用户文件整体替换内置文件**；规则不会逐条合并。例如，用户目录中的 `latex.syntax.json` 会替换内置的 `latex.syntax.json`，而 `percent-math.syntax.json` 会作为新文件追加。

加载后，所有有效规则按 `open` 的长度从长到短尝试。因此，如果同时定义 `[[` 和 `[`，匹配到 `[[` 时会先尝试较长的规则。长度相同且起始符相同的规则不要依赖文件名或数组顺序来决定胜负；请改用不同的起始符。一个规则找到结束符后，整段数学内容会被消费，不会再在其内部应用其他规则。

若想关闭内置的 `\[...\]` 和 `\(...\)`，在用户目录中创建同名文件 `latex.syntax.json`：

```json
{
  "name": "Disable bundled LaTeX delimiters",
  "enabled": false,
  "rules": []
}
```

这只关闭这个同名文件提供的规则；其他用户规则文件仍可生效。要恢复内置规则，删除或改名这个用户文件并重新渲染。若想保留其中一种内置定界符，则复制上节的完整 JSON 到用户的 `latex.syntax.json`，删除不需要的那条规则。

## 哪些内容不会改写

转换发生在 Hoedown 解析 Markdown **之前**。实现会跳过反引号行内代码、以反引号或波浪线标记的围栏代码块、以四个空格或 Tab 开头的缩进代码行，以及 `<pre>`、`<code>`、`<script>`、`<style>` 的原始 HTML 内容。它也会跳过一般 HTML 标签本身。

这是一层定界符预处理，不是完整的 Markdown 语法解析器。规则可能与普通文本或其他 Markdown 结构中的相同字符冲突；例如 `%%`、`@@` 也可能出现在非公式文字中。选择不常用的定界符，并用包含普通段落、链接、代码和公式的文档测试实际效果。

## 排查规则不生效

1. 确认 **TeX-like math syntax** 已勾选，预览窗格可见，并重新执行 **View → Render Markdown**。
2. 确认文件位于 `~/Library/Application Support/macDownMod/SyntaxExtensions/` 的顶层，文件名确实以 `.syntax.json` 结尾。Finder 可能隐藏文件扩展名，可在终端执行 `ls -la "$HOME/Library/Application Support/macDownMod/SyntaxExtensions"` 检查。
3. 执行 `python3 -m json.tool "文件完整路径" >/dev/null` 检查 JSON 语法。顶层必须是对象，`rules` 必须是数组，每条规则的 `open`、`close` 都必须是非空字符串，`kind` 必须准确写成 `displayMath` 或 `inlineMath`。格式无效的条目会被跳过；JSON 无效时应用会在日志中记录 `Invalid syntax extension`。
4. 检查是否存在同名用户文件覆盖了内置文件、`enabled` 是否为 `false`，以及是否有其他规则使用相同或更长的起始符。即使同名用户文件的 JSON 无效，它也已遮蔽对应的内置文件。
5. 检查输入是否位于代码或 HTML 区域、定界符前是否有转义反斜杠，以及起始符之后是否确实存在有效的结束符。
6. 如果规则已匹配而公式仍未排版，检查 MathJax 资源的网络加载情况。

规则实现位于 [`MPSyntaxExtensions.m`](macDownMod/Code/Extension/MPSyntaxExtensions.m)，默认文件位于 [`latex.syntax.json`](macDownMod/Resources/Extensions/latex.syntax.json)。编译与安装步骤见 [编译说明](BUILDING.zh-CN.md)。
